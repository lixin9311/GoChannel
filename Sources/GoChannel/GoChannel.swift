import Foundation

enum ChanError: Error {
    case ChannelClosed(String)
}

precedencegroup ChanSendRecv {
    associativity: left
}

infix operator <-: ChanSendRecv
public func <- <T>(c: Chan<T>, value: T?) async throws { try await c.send(value: value) }
public func <- <T>(value: inout T?, chan: Chan<T>) async throws { try value = await chan.next() }

prefix operator <-
prefix func <- <T>(chan: inout Chan<T>) -> Chan<T> { return chan.recv() }
prefix func <- <T>(chan: inout Chan<T>) async throws -> T? { return try await chan.next() }

final public class Chan<T>: AsyncSequence, AsyncIteratorProtocol {
    public typealias Element = T
    final private class Waiter {
        enum Direction: Int {
            case Receive = 0
            case Send
        }
        
        private let direction: Direction
        private var fulfilled: Bool = false
        private let sema = DispatchSemaphore(value: 0)
        var value: T? {
            get {
                if direction == .Send {
                    fulfilled = true
                    sema.signal()
                } else if !fulfilled {
                    sema.wait()
                }
                return _value
            }
            set(newValue) {
                _value = newValue
                if direction == .Receive {
                    fulfilled = true
                    sema.signal()
                } else if !fulfilled {
                    sema.wait()
                }
            }
        }
        var _value: T?
        
        init(direction: Direction) {
            self.direction = direction
        }
    }
    
    private var lock: NSLock = NSLock()
    private let capacity: Int
    private var buffer: [T?] = []
    private var sendQ: [Waiter] = []
    private var recvQ: [Waiter] = []
    private var closed: Bool = false
    
    init(_ capacity: Int = 0) {
        self.capacity = capacity
    }
    
    var count: Int {
        return buffer.count
    }
    
    func close() {
        lock.lock()
        defer { lock.unlock() }
        self.closed = true
        
        // empty recv Waiters
        for recvW in recvQ {
            recvW.value = nil
        }
        recvQ.removeAll()
        
        // empty send Waiters
        for sendW in sendQ {
            _ = sendW.value
        }
        sendQ.removeAll()
    }
    
    func send(value: T?) async throws {
        lock.lock()
        if self.closed {
            throw ChanError.ChannelClosed("send on closed channel")
        }
        // see if we can immediately pair with a waiting receiver
        if let recvW = removeWaiter(waitQ: &recvQ) {
            recvW.value = value
            lock.unlock()
            return
        }
        
        // if not, use the buffer if there's space
        if self.buffer.count < self.capacity {
            self.buffer.append(value)
            lock.unlock()
            return
        }
        
        // otherwise block until we can send
        let sendW = Waiter(direction: .Send)
        sendQ.append(sendW)
        lock.unlock()
        sendW.value = value
        if self.closed {
            throw ChanError.ChannelClosed("send on closed channel")
        }
    }
    
    func recv() -> Chan {
        return self
    }
    
    public func makeAsyncIterator() -> Chan {
        return self
    }
    
    public func remainBuffer() -> Int {
        return buffer.count
    }
    
    public func next() async throws -> T? {
        lock.lock()
        // see if there's oustanding messages in the buffer
        if buffer.count > 0 {
            let value: T? = buffer.remove(at: 0)
            
            // unblock waiting senders using buffer
            if let sendW = removeWaiter(waitQ: &sendQ) {
                buffer.append(sendW.value)
            }
            
            lock.unlock()
            return value
        }
        
        // if not, pair with any waiting senders
        if let sendW = removeWaiter(waitQ: &sendQ) {
            lock.unlock()
            return sendW.value
        }
        
        if self.closed {
            throw ChanError.ChannelClosed("channel closed")
        }
        // otherwise, block until a message is available
        let recvW = Waiter(direction: .Receive)
        recvQ.append(recvW)
        lock.unlock()
        let val = recvW.value
        if self.closed {
            throw ChanError.ChannelClosed("channel closed")
        }
        return val
    }
    
    private func removeWaiter(waitQ: inout [Waiter]) -> Waiter? {
        if waitQ.count > 0 {
            return waitQ.remove(at: 0)
        }
        return nil
    }
}

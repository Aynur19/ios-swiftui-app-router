public enum SUISwipeDirection: Sendable, Hashable {
    case left
    case right
    case up
    case down
    
    public var isHorizontal: Bool {
        self == .left || self == .right
    }
}

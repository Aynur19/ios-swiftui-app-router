import Foundation

public struct SUISwipeToPopConfig: Sendable {
    public let directions: Set<SUISwipeDirection>
    public let previousScreenVisibility: CGFloat
    
    public init(
        direction: SUISwipeDirection,
        previousScreenVisibility: CGFloat = 0.3
    ) {
        self.directions = [direction]
        self.previousScreenVisibility = previousScreenVisibility
    }
    
    public init(
        directions: Set<SUISwipeDirection>,
        previousScreenVisibility: CGFloat = 0.3
    ) {
        self.directions = directions
        self.previousScreenVisibility = previousScreenVisibility
    }
}

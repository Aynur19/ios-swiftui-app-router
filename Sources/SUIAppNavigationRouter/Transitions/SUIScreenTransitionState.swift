import SwiftUI

/// Состояние анимационных параметров экрана
public struct SUIScreenTransitionState: Equatable {
    public var opacity: Double = 0
    public var offset: CGPoint = .zero
    public var scale: CGFloat = 1.0
    public var rotation: Double = 0.0
    public var blur: CGFloat = 0.0
    
    public init(
        opacity: Double = 0,
        offset: CGPoint = .zero,
        scale: CGFloat = 1.0,
        rotation: Double = 0.0,
        blur: CGFloat = 0.0
    ) {
        self.opacity = opacity
        self.offset = offset
        self.scale = scale
        self.rotation = rotation
        self.blur = blur
    }
}

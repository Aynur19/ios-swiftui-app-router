import Foundation

public enum SUITransitionParameter {
    case opacity(value: CGFloat)
    case offset(value: CGPoint)
    case scale(value: CGFloat)
    case rotation(value: Double)
    case blur(value: CGFloat)
}

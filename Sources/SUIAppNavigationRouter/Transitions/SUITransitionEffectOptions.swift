import SwiftUI

/// Опции, определяющие, какие именно параметры применять к View
public struct SUITransitionEffectOptions: OptionSet, Sendable {
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let opacity   = SUITransitionEffectOptions(rawValue: 1 << 0)
    public static let offset    = SUITransitionEffectOptions(rawValue: 1 << 1)
    public static let scale     = SUITransitionEffectOptions(rawValue: 1 << 2)
    public static let rotation  = SUITransitionEffectOptions(rawValue: 1 << 3)
    public static let blur      = SUITransitionEffectOptions(rawValue: 1 << 4)
    
    public static let all: SUITransitionEffectOptions = [.opacity, .offset, .scale, .rotation, .blur]
    public static let `default`: SUITransitionEffectOptions = [.opacity, .offset] // Дефолтное поведение
}

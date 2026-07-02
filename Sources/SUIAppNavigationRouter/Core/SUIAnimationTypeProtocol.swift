import SwiftUI

public protocol SUIAnimationTypeProtocol: Sendable, Hashable {
    /// Возвращает готовый Animation для SwiftUI
    func animation(duration: Double) -> Animation
    
    /// Оценка длительности анимации (особенно важно для spring'ов)
    func estimatedDuration(explicit: Double?) -> Double
}

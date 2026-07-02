import SwiftUI

public enum SUIAnimationType {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case spring(response: Double, dampingFraction: Double)
    case timingCurve(Double, Double, Double, Double)
    case modernSpring(bounce: Double)
    case `default`
}
    
// MARK: - Convert to Animation
extension SUIAnimationType: SUIAnimationTypeProtocol {
    public func animation(duration: Double) -> Animation {
        switch self {
            case .linear:
                Animation.linear(duration: duration)
            
            case .easeIn:
                Animation.easeIn(duration: duration)
            
            case .easeOut:
                Animation.easeOut(duration: duration)
            
            case .easeInOut:
                Animation.easeInOut(duration: duration)
            
            case let .spring(response, dampingFraction):
                Animation.spring(response: response, dampingFraction: dampingFraction)
            
            case let .timingCurve(p1x, p1y, p2x, p2y):
                Animation.timingCurve(p1x, p1y, p2x, p2y, duration: duration)
            
            case let .modernSpring(bounce):
                modernSpring(duration: duration, bounce: bounce)
            
            case .default:
                Animation.default
        }
    }
    
    private func modernSpring(duration: Double, bounce: Double) -> Animation {
        if #available(iOS 17.0, *) {
            Animation.spring(duration: duration, bounce: bounce)
        } else {
            Animation.spring(response: duration * 0.55, dampingFraction: 0.825)
        }
    }
    
    // MARK: - Estimate Base Duration
    public func estimatedDuration(explicit: Double?) -> Double {
        if let explicit = explicit {
            return explicit
        }
        
        return switch self {
            case let .spring(response, dampingFraction):
                springDuration(response: response, dampingFraction: dampingFraction)
                
            case let .modernSpring(bounce):
                modernSpringDuration(bounce: bounce)
                
            case .default:
                defaultDuration()
                
            default:
                0.35
        }
    }
    
    private func springDuration(response: Double, dampingFraction: Double) -> Double {
        let settlingFactor = dampingFraction < 1.0 ? 5.0 : 4.0
        
        return response * settlingFactor
    }
    
    private func modernSpringDuration(bounce: Double) -> Double {
        0.5 * (1.0 + abs(bounce) * 0.5)
    }
    
    private func defaultDuration() -> Double {
        if #available(iOS 17.0, *) {
            return 0.55 * 4.0 // spring settling time
        } else {
            return 0.35 // easeInOut default
        }
    }
}

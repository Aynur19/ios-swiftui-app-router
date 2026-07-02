import SwiftUI

public struct SUIAnimationDescriptor: Sendable {
    public let type: any SUIAnimationTypeProtocol
    
    public let delay: Double
    public let repeatCount: Int?
    public let autoreverses: Bool
    public let speedMultiplier: Double
    public let explicitDuration: Double?
    
    private init(
        type: any SUIAnimationTypeProtocol,
        duration: Double? = nil,
        delay: Double = 0,
        speedMultiplier: Double = 1.0,
        repeatCount: Int? = nil,
        autoreverses: Bool = false
    ) {
        self.type = type
        self.explicitDuration = duration
        self.delay = delay
        self.speedMultiplier = speedMultiplier
        self.repeatCount = repeatCount
        self.autoreverses = autoreverses
    }
}
    
// MARK: - Computed Properties
extension SUIAnimationDescriptor {
    var animation: Animation {
        let baseDuration = type.estimatedDuration(explicit: explicitDuration)
        var anim = type.animation(duration: baseDuration)
        
        if delay > 0 {
            anim = anim.delay(delay)
        }
        
        if speedMultiplier != 1.0 {
            anim = anim.speed(speedMultiplier)
        }
        
        if let count = repeatCount {
            anim = anim.repeatCount(count, autoreverses: autoreverses)
        }
        
        return anim
    }
    
    var totalDuration: Double {
        let base = type.estimatedDuration(explicit: explicitDuration)
        let adjusted = (base / speedMultiplier) + delay
        
        guard let count = repeatCount else {
            return adjusted
        }
        
        return adjusted * Double(count)
    }
    
    var cycleDuration: Double {
        type.estimatedDuration(explicit: explicitDuration) / speedMultiplier
    }
}
    
// MARK: - Factory Methods
extension SUIAnimationDescriptor {
    public static func `default`() -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(type: SUIAnimationType.default)
    }
    
    public static func linear(duration: Double) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(type: SUIAnimationType.linear, duration: duration)
    }
    
    public static func easeIn(duration: Double) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(type: SUIAnimationType.easeIn, duration: duration)
    }
    
    public static func easeOut(duration: Double) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(type: SUIAnimationType.easeOut, duration: duration)
    }
    
    public static func easeInOut(duration: Double) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(type: SUIAnimationType.easeInOut, duration: duration)
    }
    
    public static func spring(
        response: Double = 0.55,
        dampingFraction: Double = 0.825
    ) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(type: SUIAnimationType.spring(response: response, dampingFraction: dampingFraction))
    }
    
    @available(iOS 17.0, *)
    public static func spring(
        duration: Double,
        bounce: Double = 0
    ) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(type: SUIAnimationType.modernSpring(bounce: bounce), duration: duration)
    }
    
    public static func timingCurve(
        p1x: Double,
        p1y: Double,
        p2x: Double,
        p2y: Double,
        duration: Double
    ) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(type: SUIAnimationType.timingCurve(p1x, p1y, p2x, p2y), duration: duration)
    }
    
    public static func custom(
        type: any SUIAnimationTypeProtocol,
        duration: Double? = nil
    ) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(type: type, duration: duration)
    }
}

// MARK: - Modifiers
extension SUIAnimationDescriptor {
    public func withDelay(_ delay: Double) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(
            type: type,
            duration: explicitDuration,
            delay: self.delay + delay,
            speedMultiplier: speedMultiplier,
            repeatCount: repeatCount,
            autoreverses: autoreverses
        )
    }
    
    public func withSpeed(_ speed: Double) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(
            type: type,
            duration: explicitDuration,
            delay: delay,
            speedMultiplier: speedMultiplier * speed,
            repeatCount: repeatCount,
            autoreverses: autoreverses
        )
    }
    
    public func withRepeat(count: Int, autoreverses: Bool = true) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(
            type: type,
            duration: explicitDuration,
            delay: delay,
            speedMultiplier: speedMultiplier,
            repeatCount: count,
            autoreverses: autoreverses
        )
    }
    
    public func withRepeatForever(autoreverses: Bool = true) -> SUIAnimationDescriptor {
        SUIAnimationDescriptor(
            type: type,
            duration: explicitDuration,
            delay: delay,
            speedMultiplier: speedMultiplier,
            repeatCount: nil,
            autoreverses: autoreverses
        )
    }
}

// MARK: - View Extension
extension View {
    public func applyAnimation(
        descriptor: SUIAnimationDescriptor,
        value: some Equatable
    ) -> some View {
        self.animation(descriptor.animation, value: value)
    }
}

// MARK: - withAnimation Extension
public func withAnimation<Result>(
    descriptor: SUIAnimationDescriptor,
    body: () throws -> Result
) rethrows -> Result {
    try withAnimation(descriptor.animation, body)
}

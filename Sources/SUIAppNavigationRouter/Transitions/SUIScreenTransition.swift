import SwiftUI

public struct SUIScreenTransition {
    public let animation: SUIAnimationDescriptor?
    public let startParameters: [SUITransitionParameter]
    public let endParameters: [SUITransitionParameter]
    private(set) var completion: (() -> Void)?
    
    public init(
        animation: SUIAnimationDescriptor? = nil,
        startParameters: [SUITransitionParameter],
        endParameters: [SUITransitionParameter],
        completion: (() -> Void)? = nil
    ) {
        self.animation = animation
        self.startParameters = startParameters
        self.endParameters = endParameters
    }
}

extension SUIScreenTransition {
    public func appended(completion: (() -> Void)?) -> SUIScreenTransition {
        SUIScreenTransition(
            animation: animation,
            startParameters: startParameters,
            endParameters: endParameters,
            completion: {
                self.completion?()
                completion?()
            }
        )
    }
}

extension SUIScreenTransition {
    public static func fade(
        with animation: SUIAnimationDescriptor? = SUIAnimationDescriptor.easeInOut(duration: 0.35),
        isShowing: Bool,
        completion: (() -> Void)? = nil
    ) -> SUIScreenTransition {
        let startParameters = isShowing
        ? [SUITransitionParameter.opacity(value: 0), SUITransitionParameter.offset(value: CGPoint.zero)]
        : [SUITransitionParameter.opacity(value: 1), SUITransitionParameter.offset(value: CGPoint.zero)]
        
        let endParameters = isShowing
        ? [SUITransitionParameter.opacity(value: 1), SUITransitionParameter.offset(value: CGPoint.zero)]
        : [SUITransitionParameter.opacity(value: 0), SUITransitionParameter.offset(value: CGPoint.zero)]
        
        return SUIScreenTransition(
            animation: animation,
            startParameters: startParameters,
            endParameters: endParameters,
            completion: completion
        )
    }
    
    public static func slide(
        with animation: SUIAnimationDescriptor? = SUIAnimationDescriptor.easeOut(duration: 0.35),
        from anchorStart: any SUIScreenAnchorProtocol,
        to anchorEnd: any SUIScreenAnchorProtocol,
        coef: CGFloat = 1,
        bounds: CGSize,
        completion: (() -> Void)? = nil
    ) -> SUIScreenTransition {
        let startParameters = [
            SUITransitionParameter.opacity(value: 1),
            SUITransitionParameter.offset(value: anchorStart.animationOffset(bounds: bounds, coef: coef))
        ]
        
        let endParameters = [
            SUITransitionParameter.opacity(value: 1),
            SUITransitionParameter.offset(value: anchorEnd.animationOffset(bounds: bounds, coef: coef))
        ]
        
        return SUIScreenTransition(
            animation: animation,
            startParameters: startParameters,
            endParameters: endParameters,
            completion: completion
        )
    }
}

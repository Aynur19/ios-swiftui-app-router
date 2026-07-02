import Foundation

public struct SUINavigationTransitionSlideStyle: SUINavigationTransitionStyle {
    public let anchor: any SUIScreenAnchorProtocol
    public let bounds: CGSize
    
    public init(
        from anchor: any SUIScreenAnchorProtocol,
        bounds: CGSize
    ) {
        self.anchor = anchor
        self.bounds = bounds
    }
    
    public func transition() -> SUINavigationTransition {
        let centerAnchor = SUIScreenAnchor.center
        let appearTransition = SUIScreenTransition.slide(from: anchor, to: centerAnchor, bounds: bounds)
        let disappearTransition = SUIScreenTransition
            .slide(from: centerAnchor, to: anchor.assymmetric(), coef: 0.5, bounds: bounds)
        
        return SUINavigationTransition(appearTransition: appearTransition, disappearTransition: disappearTransition)
    }
    
    public func asymmetricTransition() -> SUINavigationTransition {
        let centerAnchor = SUIScreenAnchor.center
        let appearTransition = SUIScreenTransition
            .slide(from: anchor.assymmetric(), to: centerAnchor, coef: 0.5, bounds: bounds)
        let disappearTransition = SUIScreenTransition.slide(from: centerAnchor, to: anchor, bounds: bounds)
        
        return SUINavigationTransition(appearTransition: appearTransition, disappearTransition: disappearTransition)
    }
}

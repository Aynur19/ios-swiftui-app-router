public struct SUINavigationTransitionFadeStyle: SUINavigationTransitionStyle {
    public init() {}
    
    public func transition() -> SUINavigationTransition {
        SUINavigationTransition(
            appearTransition: SUIScreenTransition.fade(isShowing: true),
            disappearTransition: SUIScreenTransition.fade(isShowing: false)
        )
    }
    
    public func asymmetricTransition() -> SUINavigationTransition {
        SUINavigationTransition(
            appearTransition: SUIScreenTransition.fade(isShowing: true),
            disappearTransition: SUIScreenTransition.fade(isShowing: false)
        )
    }
}

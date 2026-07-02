public protocol SUINavigationTransitionStyle {
    func transition() -> SUINavigationTransition
    func asymmetricTransition() -> SUINavigationTransition
}

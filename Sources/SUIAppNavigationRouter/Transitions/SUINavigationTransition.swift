public struct SUINavigationTransition {
    public let appearTransition: SUIScreenTransition
    public let disappearTransition: SUIScreenTransition
    
    public init(
        appearTransition: SUIScreenTransition,
        disappearTransition: SUIScreenTransition
    ) {
        self.appearTransition = appearTransition
        self.disappearTransition = disappearTransition
    }
}

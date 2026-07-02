public final class SUIScreenModelContainerImpl: SUIScreenModelContainer {
    public let screen: any SUIScreenProtocol
    public let viewModel: any SUIScreenViewModel
    public let stateViewModel: any SUIScreenStateViewModel
    public let transitionStyle: any SUINavigationTransitionStyle
    
    public init(
        screen: any SUIScreenProtocol,
        viewModel: any SUIScreenViewModel,
        stateViewModel: any SUIScreenStateViewModel,
        transitionStyle: any SUINavigationTransitionStyle
    ) {
        self.screen = screen
        self.viewModel = viewModel
        self.stateViewModel = stateViewModel
        self.transitionStyle = transitionStyle
    }
}

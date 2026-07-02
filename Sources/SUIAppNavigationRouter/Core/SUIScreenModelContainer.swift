public protocol SUIScreenModelContainer {
    var screen: any SUIScreenProtocol { get }
    var viewModel: any SUIScreenViewModel { get }
    var stateViewModel: any SUIScreenStateViewModel { get }
    var transitionStyle: any SUINavigationTransitionStyle { get }
}

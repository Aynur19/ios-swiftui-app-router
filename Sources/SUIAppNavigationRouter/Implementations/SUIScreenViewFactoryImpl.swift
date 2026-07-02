import SwiftUI

@MainActor
public final class SUIScreenViewFactoryImpl: SUIScreenViewFactory {
    weak var deps: (any SUIDIContainer)?
    
    private(set) var screensModels: [SUIScreenID: SUIScreenModelContainer] = [:]
    
    public init(deps: (any SUIDIContainer)) {
        self.deps = deps
    }
    
    public func screenView(for screen: any SUIScreenProtocol) -> AnyView? {
        if let viewModel = screensModels[screen.id]?.viewModel {
            return screen.screenView(viewModel: viewModel)
        }
        
        return nil
    }
    
    public func screenViewModel(for screen: any SUIScreenProtocol) -> (any SUIScreenViewModel)? {
        screensModels[screen.id]?.viewModel
    }
    
    public func screenStateViewModel(for screen: any SUIScreenProtocol) -> (any SUIScreenStateViewModel)? {
        screensModels[screen.id]?.stateViewModel
    }
    
    public func screenTransitionStyle(for screen: any SUIScreenProtocol) -> (any SUINavigationTransitionStyle)? {
        screensModels[screen.id]?.transitionStyle
    }
    
    public func add(screen: any SUIScreenProtocol, transitionStyle: SUINavigationTransitionStyle) {
        let screenModels = SUIScreenModelContainerImpl(
            screen: screen,
            viewModel: screen.screenViewModel(navigator: deps?.navigator),
            stateViewModel: SUIScreenStateViewModelImpl(),
            transitionStyle: transitionStyle
        )
    
        screensModels[screen.id] = screenModels
    }
    
    public func remove(screen: any SUIScreenProtocol) {
        screensModels[screen.id] = nil
    }
    
    public func cleanUp() {
        screensModels.removeAll()
    }
}

import SwiftUI

@MainActor
public protocol SUIScreenViewFactory {
    func screenView(for screen: any SUIScreenProtocol) -> AnyView?
    func screenViewModel(for screen: any SUIScreenProtocol) -> (any SUIScreenViewModel)?
    func screenStateViewModel(for screen: any SUIScreenProtocol) -> (any SUIScreenStateViewModel)?
    func screenTransitionStyle(for screen: any SUIScreenProtocol) -> (any SUINavigationTransitionStyle)?
    
    func add(screen: any SUIScreenProtocol, transitionStyle: SUINavigationTransitionStyle)
    func remove(screen: any SUIScreenProtocol)
    func cleanUp()
}

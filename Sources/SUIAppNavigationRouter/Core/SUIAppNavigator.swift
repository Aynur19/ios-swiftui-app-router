import SwiftUI

@MainActor
public protocol SUIAppNavigator: Sendable, ObservableObject {
    var stack: [any SUIScreenProtocol] { get }
    
    var currScreen: (any SUIScreenProtocol)? { get }
    var prevScreen: (any SUIScreenProtocol)? { get }
    var currScreenStateVM: (any SUIScreenStateViewModel)? { get }
    var prevScreenStateVM: (any SUIScreenStateViewModel)? { get }
    
    func screenView(for screen: any SUIScreenProtocol) -> AnyView?
    func screenViewModel(for screen: any SUIScreenProtocol) -> (any SUIScreenViewModel)?
    func screenStateViewModel(for screen: any SUIScreenProtocol) -> (any SUIScreenStateViewModel)?
    func screenTransitionStyle(for screen: any SUIScreenProtocol) -> (any SUINavigationTransitionStyle)?
    
    func createPath(for screen: any SUIScreenProtocol, with transitionStyle: SUINavigationTransitionStyle)
    func pushScreen(for screen: any SUIScreenProtocol, with transitionStyle: SUINavigationTransitionStyle)
    
    func popScreen(transitionStyle: SUINavigationTransitionStyle?)
    func popScreens(count: Int, transitionStyle: SUINavigationTransitionStyle?)
    func popScreens(target screen: any SUIScreenProtocol, transitionStyle: SUINavigationTransitionStyle?)
    
    func popScreen(transition: SUINavigationTransition?)
    func popScreens(count: Int, transition: SUINavigationTransition?)
    func popScreens(target screen: any SUIScreenProtocol, transition: SUINavigationTransition?)
    
    func popScreenSilently()
}

@MainActor
extension SUIAppNavigator {
    public func popScreen() {
        popScreen(transition: nil)
    }
    
    public func popScreens(count: Int) {
        popScreens(count: count, transition: nil)
    }
    
    public func popScreens(target screen: any SUIScreenProtocol) {
        popScreens(target: screen, transition: nil)
    }
    
    public func popScreen(transitionStyle: SUINavigationTransitionStyle?) {
        popScreen(transition: transitionStyle?.transition())
    }
    
    public func popScreens(count: Int, transitionStyle: SUINavigationTransitionStyle?) {
        popScreens(count: count, transition: transitionStyle?.transition())
    }
    
    public func popScreens(target screen: any SUIScreenProtocol, transitionStyle: SUINavigationTransitionStyle?) {
        popScreens(target: screen, transition: transitionStyle?.transition())
    }
}

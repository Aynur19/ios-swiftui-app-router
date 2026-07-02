import SwiftUI

//@main
struct TestNavigationRouterApp: App {
    @StateObject private var navigator = SUIDIContainerImpl.shared.navigator as! SUIAppNavigatorImpl
    
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                SUINavigationContainerView(navigator: navigator)
                    .environment(\.screenBounds, geometry.size)
                    .onAppear {
                        createPath()
                    }
            }
        }
    }
    
    private func createPath() {
        navigator.createPath(
            for: SUITransitionsScreen(uuid: UUID()),
            with: SUINavigationTransitionFadeStyle()
        )
    }
}

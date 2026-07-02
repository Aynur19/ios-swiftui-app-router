import SwiftUI

@MainActor
protocol SUITransitionsScreenViewModel: SUIScreenViewModel, ObservableObject {
    var color: Color { get }
    var hasSwipe: Bool { get }
    
    func back()
    func back(count: Int)
    func fadeTransition()
    func slideTransition(from anchor: any SUIScreenAnchorProtocol, bounds: CGSize)
}

@MainActor
final class SUITransitionsScreenViewModelImpl: SUITransitionsScreenViewModel {
    let color: Color
    let hasSwipe: Bool
    weak var navigator: (any SUIAppNavigator)?
    
    init(
        navigator: (any SUIAppNavigator)?,
        color: Color,
        hasSwipe: Bool
    ) {
        self.navigator = navigator
        self.color = color
        self.hasSwipe = hasSwipe
        SUIDebugger.print("SUITransitionsScreenViewModelImpl inited")
    }
    
    func back() {
        navigator?.popScreen()
    }
    
    func back(count: Int) {
        navigator?.popScreens(count: count)
    }
    
    func fadeTransition() {
        navigator?.pushScreen(
            for: SUITransitionsScreen(
                uuid: UUID(),
                color: Color.random,
                hasSwipe: Bool.random()
            ),
            with: SUINavigationTransitionFadeStyle()
        )
    }
    
    func slideTransition(from anchor: any SUIScreenAnchorProtocol, bounds: CGSize) {
        navigator?.pushScreen(
            for: SUITransitionsScreen(
                uuid: UUID(),
                color: Color.random,
                hasSwipe: Bool.random()
            ),
            with: SUINavigationTransitionSlideStyle(from: anchor, bounds: bounds)
        )
    }
}

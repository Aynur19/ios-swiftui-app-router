import SwiftUI

struct SUITransitionsScreen: SUIScreenProtocol, SUISwipeToPopScreen {
    var uuid: UUID
    let hasSwipe: Bool
    let color: Color
    
    init(
        uuid: UUID,
        color: Color,
        hasSwipe: Bool,
    ) {
        self.uuid = uuid
        self.color = color
        self.hasSwipe = hasSwipe
    }
    
    var id: String {
        "transitions_\(uuid.uuidString)"
    }
    
    // УКАЗЫВАЕМ, ЧТО СВОЙПАЕМ ВПРАВО (как стандартный iOS back)
    var swipeToPopConfig: SUISwipeToPopConfig? {
        hasSwipe ? SUISwipeToPopConfig(direction: .right, previousScreenVisibility: 0.3) : nil
    }
    
    func screenView(viewModel: any SUIScreenViewModel) -> AnyView? {
        guard let viewModel = viewModel as? SUITransitionsScreenViewModelImpl else {
            return nil
        }
        
        return AnyView(SUITransitionsScreenView(viewModel: viewModel))
    }
    
    func screenViewModel(navigator: (any SUIAppNavigator)?) -> any SUIScreenViewModel {
        SUIDebugger.print("SUITransitionsScreen.screenViewModel()...")
        return SUITransitionsScreenViewModelImpl(navigator: navigator, color: color, hasSwipe: hasSwipe)
    }
}

import SwiftUI

/// Основной контейнер, который рендерит стек экранов и управляет переходами.
///
/// Пример использования:
/// ```swift
/// @main
/// struct MyApp: App {
///     @StateObject private var navigator = SUIDIContainerImpl.shared.navigator
///
///     var body: some Scene {
///         WindowGroup {
///             GeometryReader { geometry in
///                 SUINavigationContainerView(navigator: navigator)
///                     .environment(\.screenBounds, geometry.size)
///                     .onAppear {
///                         navigator.createPath(
///                             for: MyRootScreen(),
///                             with: SUINavigationTransitionFadeStyle()
///                         )
///                     }
///             }
///         }
///     }
/// }
/// ```

public struct SUINavigationContainerView<Controller: SUIAppNavigator>: View {
    @ObservedObject private var navigator: Controller
    
    public init(navigator: Controller) {
        self.navigator = navigator
    }
    
    public var body: some View {
        ZStack {
            ForEach(navigator.stack, id: \.id) { page in
                screen(for: page)
                    .allowsHitTesting(isTopScreen(page))
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func screen(for screen: any SUIScreenProtocol) -> some View {
        if let viewModel = navigator.screenStateViewModel(for: screen) as? SUIScreenStateViewModelImpl {
            let baseView = ScreenView(viewModel: viewModel) {
                navigator.screenView(for: screen)
            }
            
            // ПРОВЕРЯЕМ: Если это верхний экран и он поддерживает свайп
            if isTopScreen(screen),
               let swipeScreen = screen as? any SUISwipeToPopScreen,
                let config = swipeScreen.swipeToPopConfig {
                baseView.modifier(SUISwipeToPopModifier(
                    config: config,
                    navigator: navigator,
                    currentVM: viewModel,
                    previousVM: navigator.prevScreenStateVM
                ))
            } else {
                baseView
            }
        }
    }
    
    private func isTopScreen(_ screen: any SUIScreenProtocol) -> Bool {
        navigator.stack.last?.id == screen.id
    }
}

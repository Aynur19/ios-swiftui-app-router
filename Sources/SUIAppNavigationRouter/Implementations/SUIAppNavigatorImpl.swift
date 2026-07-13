import SwiftUI

@MainActor
public final class SUIAppNavigatorImpl: SUIAppNavigator {
    @Published public private(set) var stack: [any SUIScreenProtocol] = []
    @Published private(set) var isTransitioning = false
    
    weak var deps: (any SUIDIContainer)?
    
    public init(deps: SUIDIContainer) {
        self.deps = deps
    }
}

@MainActor
extension SUIAppNavigatorImpl {
    private var screenViewFactory: SUIScreenViewFactory? {
        deps?.screenViewFactory
    }
    
    public var currScreen: (any SUIScreenProtocol)? {
        stack.last
    }
    
    public var prevScreen: (any SUIScreenProtocol)? {
        stack[safe: stack.count - 2]
    }
    
    public var currScreenStateVM: (any SUIScreenStateViewModel)? {
        guard let currScreen else {
            return nil
        }
        
        return screenViewFactory?.screenStateViewModel(for: currScreen)
    }
    
    public var prevScreenStateVM: (any SUIScreenStateViewModel)? {
        guard let prevScreen else {
            return nil
        }
        
        return screenViewFactory?.screenStateViewModel(for: prevScreen)
    }
}
    
@MainActor
extension SUIAppNavigatorImpl {
    public func screenView(for screen: any SUIScreenProtocol) -> AnyView? {
        screenViewFactory?.screenView(for: screen)
    }
    
    public func screenViewModel(for screen: any SUIScreenProtocol) -> (any SUIScreenViewModel)? {
        screenViewFactory?.screenViewModel(for: screen)
    }
    
    public func screenStateViewModel(for screen: any SUIScreenProtocol) -> (any SUIScreenStateViewModel)? {
        screenViewFactory?.screenStateViewModel(for: screen)
    }
    
    public func screenTransitionStyle(for screen: any SUIScreenProtocol) -> (any SUINavigationTransitionStyle)? {
        screenViewFactory?.screenTransitionStyle(for: screen)
    }
}
    
@MainActor
extension SUIAppNavigatorImpl {
    private func appearScreen(for screen: (any SUIScreenProtocol)?, with transition: SUIScreenTransition?) {
        guard let screen else { return }
        
        screenStateViewModel(for: screen)?.appearView(transition: transition)
    }
    
    private func holdScreen(for screen: (any SUIScreenProtocol)?, with transition: SUIScreenTransition?) {
        guard let screen else { return }
        
        screenStateViewModel(for: screen)?.holdView(transition: transition)
    }
    
    private func disappearScreen(for screen: (any SUIScreenProtocol)?, with transition: SUIScreenTransition?) {
        guard let screen else { return }
        
        screenStateViewModel(for: screen)?.disappearView(transition: transition)
    }
    
    private func deinitScreen(for screen: (any SUIScreenProtocol)?, with transition: SUIScreenTransition?) {
        guard let screen else { return }

        screenStateViewModel(for: screen)?.deinitView(transition: transition)
    }
}

@MainActor
extension SUIAppNavigatorImpl {
    public func createPath(
        for screen: any SUIScreenProtocol,
        with transitionStyle: SUINavigationTransitionStyle
    ) {
        guard !isTransitioning else {
            SUIDebugger.print("⚠️ Navigation blocked: transition in progress")
            return
        }
        
        SUIDebugger.print("📌 createPath called for screen: \(screen.id)")
        
        isTransitioning = true
        removeAll()
        add(screen: screen, transitionStyle: transitionStyle)
        createPath(appearScreen: screen, transition: transitionStyle.transition())
        
        printStackState("✅ createPath completed")
    }
    
    private func createPath(
        appearScreen: any SUIScreenProtocol,
        transition: SUINavigationTransition
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.appearScreen(for: appearScreen, with: transition.appearTransition)
            
            let duration = duration(appearTransition: transition.appearTransition, disappearTransition: nil)
            self.finishTransition(duration: duration)
        }
    }
    
    public func pushScreen(
        for screen: any SUIScreenProtocol,
        with transitionStyle: SUINavigationTransitionStyle
    ) {
        guard !isTransitioning else {
            SUIDebugger.print("⚠️ Navigation blocked: transition in progress")
            return
        }
        
        guard let holdedScreen = currScreen else {
            createPath(for: screen, with: transitionStyle)
            return
        }
        
        SUIDebugger.print("➕ pushScreen called for: \(screen.id)")
        
        isTransitioning = true
        add(screen: screen, transitionStyle: transitionStyle)
        pushScreen(
            appearedScreen: screen,
            holdedScreen: holdedScreen,
            transition: transitionStyle.transition()
        )
        
        printStackState("✅ pushScreen completed")
    }
    
    private func pushScreen(
        appearedScreen: any SUIScreenProtocol,
        holdedScreen: any SUIScreenProtocol,
        transition: SUINavigationTransition
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.appearScreen(for: appearedScreen, with: transition.appearTransition)
            self.holdScreen(for: holdedScreen, with: transition.disappearTransition)
            
            let duration = duration(
                appearTransition: transition.appearTransition,
                disappearTransition: transition.disappearTransition
            )
            self.finishTransition(duration: duration)
        }
    }
    
    public func popScreen(transition: SUINavigationTransition?) {
        guard let appearedScreen = prevScreen else { return }
        
        popScreens(target: appearedScreen, transition: transition)
    }
    
    public func popScreens(count: Int, transition: SUINavigationTransition?) {
        let index = max(0, stack.count - 1 - count)
        
        popScreens(target: stack[index], transition: transition)
    }
    
    public func popScreens(
        target screen: any SUIScreenProtocol,
        transition: SUINavigationTransition?
    ) {
        guard !isTransitioning else {
            SUIDebugger.print("⚠️ Navigation blocked: transition in progress")
            return
        }
        
        guard stack.count > 1,
              let disappearedScreen = currScreen,
              disappearedScreen.id != screen.id
        else { return }
        
        let transition = transition
        ?? screenTransitionStyle(for: disappearedScreen)?.asymmetricTransition()
        ?? SUINavigationTransitionFadeStyle().asymmetricTransition()
        
        isTransitioning = true
        var removedScreens = [any SUIScreenProtocol]()
        for index in stride(from: stack.count - 1, to: -1, by: -1) {
            if stack[index].id == screen.id {
                break
            }
            
            if index == 0 {
                return
            }
            
            removedScreens.append(stack[index])
        }
        
        popScreens(
            appearedScreen: screen,
            disappearedScreen: disappearedScreen,
            removedScreens: removedScreens,
            transition: transition
        )
    }
    
    private func popScreens(
        appearedScreen: any SUIScreenProtocol,
        disappearedScreen: any SUIScreenProtocol,
        removedScreens: [any SUIScreenProtocol],
        transition: SUINavigationTransition
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            removedScreens.forEach { screen in
                if screen.id != disappearedScreen.id {
                    self.deinitScreen(for: screen, with: SUIScreenTransition.fade(with: nil, isShowing: false))
                }
            }
            self.disappearScreen(for: disappearedScreen, with: transition.disappearTransition)
            self.appearScreen(for: appearedScreen, with: transition.appearTransition)
            
            let duration = duration(
                appearTransition: transition.appearTransition,
                disappearTransition: transition.disappearTransition
            )
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                guard let self else { return }
                
                self.remove(screens: removedScreens)
                SUIDebugger.print("⏱️ Animation completed, cleaning up...")
                self.isTransitioning = false
            }
        }
    }
    
    private func finishTransition(duration: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.isTransitioning = false
            self?.enforceSingleVisibleScreenRule()
        }
    }
    
    private func duration(
        appearTransition: SUIScreenTransition?,
        disappearTransition: SUIScreenTransition?
    ) -> Double {
        return max(
            appearTransition?.animation?.totalDuration ?? 0.35,
            disappearTransition?.animation?.totalDuration ?? 0.35
        ) + 0.1
    }
    
    public func popScreenSilently() {
        guard let disappearedScreen = currScreen else { return }
        
        remove(screen: disappearedScreen)
        enforceSingleVisibleScreenRule()
        
    }

    private func enforceSingleVisibleScreenRule() {
        guard let topScreen = stack.last else { return }
        for screen in stack {
            if screen.id == topScreen.id {
                // Верхний экран всегда полностью видим и на месте
                screenStateViewModel(for: screen)?.setOffsetDirectly(.zero)
                screenStateViewModel(for: screen)?.setVisibilityDirectly(1.0)
            } else {
                screenStateViewModel(for: screen)?.setVisibilityDirectly(0.0)
            }
        }
    }
}

@MainActor
extension SUIAppNavigatorImpl {
    private func removeAll() {
        stack.removeAll()
        screenViewFactory?.cleanUp()
    }
    
    private func add(screen: any SUIScreenProtocol, transitionStyle: SUINavigationTransitionStyle) {
        screenViewFactory?.add(screen: screen, transitionStyle: transitionStyle)
        stack.append(screen)
    }
    
    private func remove(screens: [any SUIScreenProtocol]) {
        SUIDebugger.print("🗑️ Removing screens count: \(screens.count)")
        
        for screen in screens {
            remove(screen: screen)
        }
  
        printStackState("✅ cleanUpLastScreen completed")
    }
    
    private func remove(screen: any SUIScreenProtocol) {
        if let index = stack.lastIndex(where: { $0.id == screen.id }) {
            stack.remove(at: index)
        }
        
        screenViewFactory?.remove(screen: screen)
    }
}

// MARK: - Debug Helpers
@MainActor
extension SUIAppNavigatorImpl {
    private func printStackState(_ action: String) {
        SUIDebugger.print("🔍 [Navigator] \(action)")
        SUIDebugger.print("   Stack count: \(stack.count) | IDs: \(stack.map { String($0.id.prefix(8)) })")
        SUIDebugger.print("   ───────────────────────────────")
    }
}

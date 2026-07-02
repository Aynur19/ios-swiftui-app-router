import SwiftUI

@MainActor
public final class SUIScreenStateViewModelImpl: SUIScreenStateViewModel {
    @Published public private(set) var transitionState: SUIScreenTransitionState = .init()
    
    @Published public private(set) var state: SUIScreenState = .onInited {
        didSet { transition(from: oldValue, to: state) }
    }
    
    private var transition: SUIScreenTransition?
    private var currentAnimationCompletion: (() -> Void)?
}

@MainActor
extension SUIScreenStateViewModelImpl {
    public func setOffsetDirectly(_ offset: CGPoint) {
        // Так как transitionState это структура (value type),
        // мы мутруем её свойство, и @Published автоматически уведомит View об изменении.
        self.transitionState.offset = offset
    }
    
    public func setOpacityDirectly(_ opacity: Double) {
        self.transitionState.opacity = opacity
    }
    
    // MARK: - Appear view
    public func appearView(transition: SUIScreenTransition?) {
        self.transition = transition
        process(event: SUIScreenEvent.startAppearing)
    }
    
    private func startAppearing() {
        if let transition {
            updateParameters(parameters: transition.startParameters)
            
            tryAnimate(transition: transition) { [weak self] in
                self?.process(event: SUIScreenEvent.endAppearing)
            }
        }
    }
    
    private func endAppearing() {
        transition?.completion?()
    }
    
    // MARK: - Hold view
    public func holdView(transition: SUIScreenTransition?) {
        self.transition = transition
        process(event: SUIScreenEvent.startHolding)
    }
    
    private func startHolding() {
        if let transition {
            updateParameters(parameters: transition.startParameters)
            
            tryAnimate(transition: transition) { [weak self] in
                self?.process(event: SUIScreenEvent.endHolding)
            }
        }
    }
    
    private func endHolding() {
        transition?.completion?()
    }
    
    // MARK: - Disappear view
    public func disappearView(transition: SUIScreenTransition?) {
        self.transition = transition
        process(event: SUIScreenEvent.startDisappearing)
    }
    
    private func startDisappearing() {
        if let transition {
            updateParameters(parameters: transition.startParameters)
            
            tryAnimate(transition: transition) { [weak self] in
                self?.process(event: SUIScreenEvent.endDisappearing)
            }
        }
    }
    
    private func endDisappearing() {
        transition?.completion?()
    }
    
    // MARK: - Deinit view
    public func deinitView(transition: SUIScreenTransition?) {
        self.transition = transition
        process(event: SUIScreenEvent.startDeiniting)
    }
    
    private func startDeiniting() {
        if let transition {
            updateParameters(parameters: transition.startParameters)
            
            tryAnimate(transition: transition) { [weak self] in
                self?.process(event: SUIScreenEvent.endDeiniting)
            }
        }
    }
    
    private func endDeiniting() {
        transition?.completion?()
    }
}

@MainActor
extension SUIScreenStateViewModelImpl {
    private func tryAnimate(
        transition: SUIScreenTransition?,
        completion: (() -> Void)? = nil
    ) {
        guard let transition else {
            completion?()
            return
        }
        
        guard let animationDescriptor = transition.animation else {
            updateParameters(parameters: transition.endParameters)
            completion?()
            return
        }
        
        let animation = animationDescriptor.animation
        currentAnimationCompletion = completion
        
        withAnimation(animation) {
            updateParameters(parameters: transition.endParameters)
        }
        
        let duration = animationDescriptor.totalDuration + 0.1
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self else { return }
            currentAnimationCompletion?()
            currentAnimationCompletion = nil
        }
    }
    
    private func updateParameters(parameters: [SUITransitionParameter]) {
        for parameter in parameters {
            switch parameter {
                case let .opacity(value): transitionState.opacity = value
                case let .offset(value):  transitionState.offset = value
                case let .scale(value):   transitionState.scale = value
                case let .rotation(value): transitionState.rotation = value
                case let .blur(value):    transitionState.blur = value
            }
        }
    }
}

@MainActor
extension SUIScreenStateViewModelImpl {
    private func process(event: SUIScreenEvent) {
        switch (state, event) {
            case (.onInited, .startAppearing):          state = .onAppearing
            case (.onInited, .startDeiniting):          state = .onDeiniting
                
            case (.onAppeared, .startHolding):          state = .onHolding
            case (.onAppeared, .startDisappearing):     state = .onDisappearing
            case (.onAppeared, .startDeiniting):        state = .onDeiniting
                
            case (.onHolded, .startAppearing):          state = .onAppearing
            case (.onHolded, .startDeiniting):          state = .onDeiniting
            case (.onDisappeared, .startDeiniting):     state = .onDeiniting
                
            case (.onAppearing, .endAppearing):         state = .onAppeared
            case (.onHolding, .endHolding):             state = .onHolded
            case (.onDisappearing, .endDisappearing):   state = .onDisappeared
            case (.onDeiniting, .endDeiniting):         state = .onDeinited
                
            default:
                SUIDebugger.assertionFailure("Navigation warning: invalid state transition \(state) + \(event)")
        }
    }
    
    // выполнение действий при переходе между состояниями
    private func transition(from oldState: SUIScreenState, to currentState: SUIScreenState) {
        switch (oldState, currentState) {
            case (.onInited, .onAppearing):         startAppearing()
            case (.onInited, .onDeiniting):         startDeiniting()
            case (.onAppearing, .onAppeared):       endAppearing()
            case (.onAppearing, .onDeiniting):      startDeiniting()
            case (.onAppeared, .onHolding):         startHolding()
            case (.onAppeared, .onDisappearing):    startDisappearing()
            case (.onAppeared, .onDeiniting):       startDeiniting()
            case (.onHolding, .onHolded):           endHolding()
            case (.onHolding, .onDeiniting):        startDeiniting()
            case (.onHolded, .onAppearing):         startAppearing()
            case (.onHolded, .onDeiniting):         startDeiniting()
            case (.onDisappearing, .onDisappeared): endDisappearing()
            case (.onDisappearing, .onDeiniting):   startDeiniting()
            case (.onDisappeared, .onDeiniting):    startDeiniting()
            case (.onDeiniting, .onDeinited):       endDeiniting()
            
            default:
                SUIDebugger.assertionFailure("Navigation warning: invalid state transition \(oldState) + \(currentState)")
        }
    }
}

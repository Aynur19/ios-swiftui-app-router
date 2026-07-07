import SwiftUI

public struct SUIScreenTransitionStateKey: EnvironmentKey {
    public static let defaultValue: SUIScreenState = .onInited
}

extension EnvironmentValues {
    /// Возвращает текущее состояние экрана в навигаторе (onAppeared, onHolding и т.д.)
    public var screenTransitionState: SUIScreenState {
        get { self[SUIScreenTransitionStateKey.self] }
        set { self[SUIScreenTransitionStateKey.self] = newValue }
    }
}

import SwiftUI

public struct SUIScreenVisibilityProgressKey: EnvironmentKey {
    public static let defaultValue: Double = 1.0
}

extension EnvironmentValues {
    /// Возвращает прогресс транзишена экрана (1.0 - активен, < 1.0 - в фоне/уходит)
    public var screenVisibilityProgress: Double {
        get { self[SUIScreenVisibilityProgressKey.self] }
        set { self[SUIScreenVisibilityProgressKey.self] = newValue }
    }
}

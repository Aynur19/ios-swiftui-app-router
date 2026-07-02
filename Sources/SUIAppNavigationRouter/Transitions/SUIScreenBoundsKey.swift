import SwiftUI

public struct SUIScreenBoundsKey: EnvironmentKey {
    public static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    public var screenBounds: CGSize {
        get { self[SUIScreenBoundsKey.self] }
        set { self[SUIScreenBoundsKey.self] = newValue }
    }
}

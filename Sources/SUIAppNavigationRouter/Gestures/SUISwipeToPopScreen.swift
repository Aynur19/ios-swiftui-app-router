/// Протокол, который нужно добавить к экрану для поддержки свайпа назад.
///
/// Пример реализации:
/// ```swift
/// struct MyScreen: SUIScreenProtocol, SUISwipeToPopScreen {
///     var id: String { "my_screen" }
///     var swipeToPopConfig: SUISwipeToPopConfig? {
///         SUISwipeToPopConfig(direction: .right, previousScreenVisibility: 0.3)
///     }
///     // ...
/// }
/// ```

public protocol SUISwipeToPopScreen: SUIScreenProtocol {
    var swipeToPopConfig: SUISwipeToPopConfig? { get }
}

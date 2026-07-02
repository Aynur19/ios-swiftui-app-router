import SwiftUI

public struct SUIScreenTransitionModifier: ViewModifier {
    let state: SUIScreenTransitionState
    let options: SUITransitionEffectOptions
    
    public func body(content: Content) -> some View {
        content
            .applyIf(options.contains(.opacity)) { view in
                view.opacity(state.opacity)
            }
            .applyIf(options.contains(.offset)) { view in
                view.offset(x: state.offset.x, y: state.offset.y)
            }
            .applyIf(options.contains(.scale)) { view in
                view.scaleEffect(state.scale)
            }
            .applyIf(options.contains(.rotation)) { view in
                view.rotationEffect(.degrees(state.rotation))
            }
            .applyIf(options.contains(.blur)) { view in
                view.blur(radius: state.blur)
            }
    }
}

// Вспомогательный extension для чистоты кода
extension View {
    @ViewBuilder
    func applyIf(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

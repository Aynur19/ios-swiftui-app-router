import SwiftUI

public struct ScreenView<Content: View, ViewModel: SUIScreenStateViewModel>: View {
    @ObservedObject private var viewModel: ViewModel
    private let options: SUITransitionEffectOptions
    private let content: (() -> Content)
    
    public init(
        viewModel: ViewModel,
        @ViewBuilder content: @escaping (() -> Content)
    ) {
        self.init(
            viewModel: viewModel,
            options: SUITransitionEffectOptions.default,
            content: content
        )
    }
    
    public init(
        viewModel: ViewModel,
        options: SUITransitionEffectOptions,
        content: @escaping (() -> Content)
    ) {
        self.viewModel = viewModel
        self.options = options
        self.content = content
    }
    
    public var body: some View {
        content()
            .modifier(SUIScreenTransitionModifier(
                state: viewModel.transitionState,
                options: options
            ))
    }
}

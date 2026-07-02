import SwiftUI

struct SUITransitionsScreenView<ViewModel: SUITransitionsScreenViewModel>: View {
    @Environment(\.screenBounds) var screenBounds: CGSize
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        print("SUITransitionsScreenView inited")
    }
    
    var body: some View {
        ZStack {
            viewModel.color.ignoresSafeArea()
            
            VStack(alignment: HorizontalAlignment.center) {
                Text(title)
                    .font(.title)
                
                backButtonView.cornerRadius(10)
                fadeTransitionsButtons.cornerRadius(10)
                sladeTransitionsButtons.cornerRadius(10)
            }
            .padding(.horizontal, 32)
        }
        .font(.system(size: 16))
        .foregroundColor(.white)
    }
    
    private var title: String {
        if viewModel.hasSwipe {
            "Transitions with swipe"
        } else {
            "Transitions"
        }
    }
    
    private var backButtonView: some View {
        HStack {
            buttonView(
                text: "Back",
                action: { viewModel.back() }
            )
            
            Spacer()
            
            buttonView(
                text: "Back to 3",
                action: { viewModel.back(count: 3) }
            )
            
            Spacer()
        }
    }
    
    private var fadeTransitionsButtons: some View {
        VStack {
            Text("Fade transitions")
            buttonView(
                text: "Opacity",
                action: { viewModel.fadeTransition() }
            )
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var sladeTransitionsButtons: some View {
        VStack {
            Text("Slide transitions")
            topSladeTransitionsButtons
            centerSladeTransitionsButtons
            bottomSladeTransitionsButtons
        }
        .padding(8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
    }
    
    private var topSladeTransitionsButtons: some View {
        HStack {
            buttonView(
                text: "Top-left",
                action: { viewModel.slideTransition(from: SUIScreenAnchor.topLeft, bounds: screenBounds) }
            )
            
            Spacer()
            buttonView(
                text: "Top",
                action: { viewModel.slideTransition(from: SUIScreenAnchor.topCenter, bounds: screenBounds) }
            )
            Spacer()
            
            buttonView(
                text: "Top-right",
                action: { viewModel.slideTransition(from: SUIScreenAnchor.topRight, bounds: screenBounds) }
            )
        }
    }
    
    private var centerSladeTransitionsButtons: some View {
        HStack {
            buttonView(
                text: "Left",
                action: { viewModel.slideTransition(from: SUIScreenAnchor.centerLeft, bounds: screenBounds) }
            )
            
            Spacer()
            buttonView(
                text: "Center",
                action: { viewModel.slideTransition(from: SUIScreenAnchor.center, bounds: screenBounds) }
            )
            Spacer()
            
            buttonView(
                text: "Right",
                action: { viewModel.slideTransition(from: SUIScreenAnchor.centerRight, bounds: screenBounds) }
            )
        }
    }
    
    private var bottomSladeTransitionsButtons: some View {
        HStack {
            buttonView(
                text: "Bottom-left",
                action: { viewModel.slideTransition(from: SUIScreenAnchor.bottomLeft, bounds: screenBounds) }
            )
            
            Spacer()
            buttonView(
                text: "Bottom",
                action: { viewModel.slideTransition(from: SUIScreenAnchor.bottomCenter, bounds: screenBounds) }
            )
            Spacer()
            
            buttonView(
                text: "Bottom-right",
                action: { viewModel.slideTransition(from: SUIScreenAnchor.bottomRight, bounds: screenBounds) }
            )
        }
    }
    
    private func buttonView(text: String, action: (() -> Void)?) -> some View {
        Button(
            action: { action?() },
            label: { Text(text) }
        )
        .padding(8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
    }
}

# iOS SwiftUI App Router

[English](README.md) | [Русский](README.ru.md)

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/Platforms-iOS%2016%2B%20%7C%20macOS%2013%2B-blue.svg" alt="Platforms"></a>
  <a href="https://swift.org/package-manager"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg" alt="SPM"></a>
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
</p>

**SUIAppNavigationRouter** is a powerful, highly customizable navigation engine for SwiftUI (iOS 16+).

Standard `NavigationStack` works well for basic cases, but when you need full control over animations, non-standard transitions (slide from any corner), or interactive multi-directional swipe-to-pop — it falls short.

This package uses a **Coordinator-friendly architecture** combined with a **custom State Machine**, moving transition logic out of Views into a managed model.

## ✨ Key Features

- 🎛 **State Machine** — Full control over screen lifecycle (Appear → Hold → Disappear → Deinit) without relying on `onAppear`
- 🎨 **Pluggable transitions** — Easily attachable animation styles (Fade, Slide from 9 directions, create your own)
- 👆 **Interactive swipe-to-pop** — Support for single or multi-axis gestures at the same time. Configurable parallax for the previous screen
- 🛡 **Safety** — Protection against gesture vector jitter, navigation blocked during animation
- 🧩 **Modular** — Strict separation (Core, Implementations, Transitions, Gestures, Utils). Easy to extend or replace parts
- 📦 **Zero dependencies** — Pure SwiftUI, no UIKit for animation calculations

## 📋 Requirements

- iOS 16.0+
- macOS 13.0+
- Xcode 15+
- Swift 6.0+

## 🚀 Installation

### Swift Package Manager

In Xcode go to **File → Add Package Dependencies...** and paste:

```
https://github.com/ambientphantom/ios-swiftui-app-router.git
```

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ambientphantom/ios-swiftui-app-router.git", from: "1.0.0")
]
```

Then add the product `SUIAppNavigationRouter` to your target.

## 🏁 Quick Start

### 1. Setup container

Wrap the root of your app in `SUINavigationContainerView` and pass screen size via Environment:

```swift
import SwiftUI
import SUIAppNavigationRouter

@main
struct MyApp: App {
    @StateObject private var navigator = SUIDIContainerImpl.shared.navigator

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                SUINavigationContainerView(navigator: navigator)
                    .environment(\.screenBounds, geometry.size)
                    .onAppear {
                        navigator.createPath(
                            for: MainScreen(),
                            with: SUINavigationTransitionFadeStyle()
                        )
                    }
            }
        }
    }
}
```

### 2. Create a screen

Every screen must conform to `SUIScreenProtocol`:

```swift
import SwiftUI
import SUIAppNavigationRouter

struct MainScreen: SUIScreenProtocol {
    var id: String { "main_screen" }
    
    func screenView(viewModel: any SUIScreenViewModel) -> AnyView? {
        guard let vm = viewModel as? MainViewModel else { return nil }
        return AnyView(MainView(viewModel: vm))
    }
    
    func screenViewModel(navigator: (any SUIAppNavigator)?) -> any SUIScreenViewModel {
        MainViewModel(navigator: navigator)
    }
}
```

### 3. Navigation (Push / Pop)

In your ViewModel just call navigator methods:

```swift
final class MainViewModel: SUIScreenViewModel, ObservableObject {
    weak var navigator: (any SUIAppNavigator)?
    
    func openDetails() {
        navigator?.pushScreen(
            for: DetailsScreen(),
            with: SUINavigationTransitionSlideStyle(from: .centerRight, bounds: /* pass from View */)
        )
    }
    
    func goBack() {
        navigator?.popScreen()
    }
}
```

## 👆 Interactive Swipes

To enable swipe-to-pop for a specific screen, conform to `SUISwipeToPopScreen`:

```swift
struct DetailsScreen: SUIScreenProtocol, SUISwipeToPopScreen {
    var id: String { "details_screen" }
    
    // Swipe only to the right, previous screen visible at 30%
    var swipeToPopConfig: SUISwipeToPopConfig? {
        SUISwipeToPopConfig(direction: .right, previousScreenVisibility: 0.3)
    }
    
    // ... rest of SUIScreenProtocol
}
```

You can also allow multi-directional swipes (up/down/left/right). In that case the previous screen stays centered.

## 🏗 Architecture

The package is strictly modular under `Sources/SUIAppNavigationRouter/`:

- **Core** — Screen protocols, ViewModels, State Machine, DI container
- **Implementations** — Stack implementation, screen factory, rendering (`SUINavigationContainerView`)
- **Transitions** — Animation descriptors, parameters (Opacity, Offset, Scale), view modifiers and styles (Fade, Slide)
- **Gestures** — Swipe configuration and `DragGesture` modifier
- **Utils** — Debug logger and safe subscripts

Usage examples and DI container setup live in the `/Examples` folder.

## 📄 License

This project is released under the MIT License. See [LICENSE.md](LICENSE.md) for details.
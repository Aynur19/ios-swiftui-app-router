# iOS SwiftUI App Router

[English](README.md) | [Русский](README.ru.md)

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/Platforms-iOS%2016%2B%20%7C%20macOS%2013%2B-blue.svg" alt="Platforms"></a>
  <a href="https://swift.org/package-manager"><img src="https://img.shields.io/badge/SPM-compatible-brightgreen.svg" alt="SPM"></a>
  <a href="LICENSE.md"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
</p>

**SUIAppNavigationRouter** — мощный и гибко настраиваемый движок навигации для SwiftUI (iOS 16+).

Стандартный `NavigationStack` хорошо подходит для простых задач, но когда нужен полный контроль над анимациями, нестандартные переходы (slide из любого угла) или интерактивные свайпы назад по нескольким осям — его возможностей недостаточно.

Пакет использует **архитектуру, дружественную к Координаторам**, в сочетании с **кастомной конечной машиной состояний (State Machine)**, вынося логику переходов из View в управляемую модель.

## ✨ Ключевые возможности

- 🎛 **State Machine** — Полный контроль жизненного цикла экрана (Appear → Hold → Disappear → Deinit) без привязки к `onAppear`
- 🎨 **Плагинные переходы** — Легко подключаемые стили анимаций (Fade, Slide из 9 направлений, возможность создать свои)
- 👆 **Интерактивные свайпы (Swipe-to-Pop)** — Поддержка свайпа назад по одной или нескольким осям одновременно. Настройка параллакса для предыдущего экрана
- 🛡 **Безопасность** — Защита от дерганий при смене вектора жеста, блокировка навигации во время анимации
- 🧩 **Модульность** — Строгое разделение (Core, Implementations, Transitions, Gestures, Utils). Легко расширять или заменять части системы
- 📦 **0 зависимостей** — Чистый SwiftUI, без использования UIKit для расчёта анимаций

## 📋 Требования

- iOS 16.0+
- macOS 13.0+
- Xcode 15+
- Swift 6.0+

## 🚀 Установка

### Swift Package Manager

В Xcode перейдите в **File → Add Package Dependencies...** и вставьте:

```
https://github.com/ambientphantom/ios-swiftui-app-router.git
```

Или в `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ambientphantom/ios-swiftui-app-router.git", from: "1.0.0")
]
```

Затем добавьте продукт `SUIAppNavigationRouter` в ваш target.

## 🏁 Быстрый старт

### 1. Настройка контейнера

Оберните корневой вид приложения в `SUINavigationContainerView` и передайте размер экрана через Environment:

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

### 2. Создание экрана

Каждый экран должен соответствовать протоколу `SUIScreenProtocol`:

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

### 3. Навигация (Push / Pop)

В вашей ViewModel просто вызывайте методы навигатора:

```swift
final class MainViewModel: SUIScreenViewModel, ObservableObject {
    weak var navigator: (any SUIAppNavigator)?
    
    func openDetails() {
        navigator?.pushScreen(
            for: DetailsScreen(),
            with: SUINavigationTransitionSlideStyle(from: .centerRight, bounds: /* передайте из View */)
        )
    }
    
    func goBack() {
        navigator?.popScreen()
    }
}
```

## 👆 Интерактивные свайпы

Чтобы включить свайп назад для конкретного экрана, добавьте соответствие протоколу `SUISwipeToPopScreen`:

```swift
struct DetailsScreen: SUIScreenProtocol, SUISwipeToPopScreen {
    var id: String { "details_screen" }
    
    // Свайп только вправо, предыдущий экран виден на 30%
    var swipeToPopConfig: SUISwipeToPopConfig? {
        SUISwipeToPopConfig(direction: .right, previousScreenVisibility: 0.3)
    }
    
    // ... остальная реализация SUIScreenProtocol
}
```

Можно также разрешить свайп в несколько сторон одновременно (вверх/вниз/влево/вправо). В этом случае предыдущий экран остаётся по центру.

## 🏗 Архитектура

Пакет строго модульный и находится в `Sources/SUIAppNavigationRouter/`:

- **Core** — Протоколы экранов, ViewModel'и, State Machine, DI-контейнер
- **Implementations** — Реализация стека, фабрика экранов, рендеринг (`SUINavigationContainerView`)
- **Transitions** — Дескрипторы анимаций, параметры (Opacity, Offset, Scale), модификаторы вью и стили (Fade, Slide)
- **Gestures** — Конфигурация свайпов и модификатор обработки `DragGesture`
- **Utils** — Debug-логгер и безопасные сабскрипты

Примеры использования и настройка DI-контейнера находятся в папке `/Examples`.

## 📄 Лицензия

Проект распространяется под лицензией MIT. Подробности в файле [LICENSE.md](LICENSE.md).
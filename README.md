# iOS SwiftUI App Router

<p align="center">
    <img src="https://img.shields.io/badge/iOS-16.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Swift-6.0+-orange.svg" />
    <img src="https://img.shields.io/badge/License-MIT-green.svg" />
</p>

**`ios-swiftui-app-router`** — это движок навигации и роутинга для SwiftUI. 
Стандартный `NavigationStack` отлично подходит для базовых задач, но когда вам нужен полный контроль над анимациями, нестандартные переходы (slide из любого угла) или интерактивные свайпы назад по нескольким осям — он подходит плохо.

Этот пакет предлагает архитектуру на основе **Координаторов** и **Конечной машины состояний (State Machine)**, вынося логику переходов из View в управляемую модель.

## ✨ Ключевые возможности

- 🎛 **State Machine:** Полный контроль жизненного цикла экрана (Appear, Hold, Disappear, Deinit) без привязки к `onAppear` вьюшек.
- 🎨 **Плагинные переходы:** Легко подключаемые стили анимаций (Fade, Slide из 9 точек, возможность создать свои).
- 👆 **Интерактивные свайпы (Swipe-to-Pop):** Поддержка свайпа назад по одной или нескольким осям одновременно. Настройка параллакса для нижнего экрана.
- 🛡 **Безопасность:** Защита от дерганий при смене вектора жеста, блокировка навигации во время анимации.
- 🧩 **Модульность:** Строгая архитектура (Core, Navigation, Transitions, Gestures). Легко расширять или заменять части системы.
- 📦 **0 зависимостей:** Чистый SwiftUI, без использования `UIKit` для расчета анимаций.

## 📋 Требования
- iOS 16.0+
- Xcode 15+
- Swift 6.0+


## 🚀 Установка
### Swift Package Manager
В Xcode перейдите в `File -> Add Package Dependencies...` и вставьте URL репозитория:

```text
https://github.com/aynur19/ios-swiftui-app-router.git
```

## 🏁 Быстрый старт
### 1. Настройка контейнера
Оберните корневой вид вашего приложения в `SUINavigationContainerView` и передайте размер экрана через Environment.

```swift
import SwiftUI
import Swinavigation // Имя твоего пакета

@main
struct MyApp: App {
    // Инициализируем навигатор (через ваш DI контейнер)
    @StateObject private var navigator = SUIDIContainerImpl.shared.navigator 

    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                SUINavigationContainerView(navigator: navigator)
                    .environment(\.screenBounds, geometry.size)
                    .onAppear {
                        // Устанавливаем корневой экран
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
Каждый экран должен conformить протокол `SUIScreenProtocol`.

```swift
import SwiftUI
import Swinavigation

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

Чтобы включить свайп назад для конкретного экрана, просто добавьте протокол `SUISwipeToPopScreen`:

```swift
struct DetailsScreen: SUIScreenProtocol, SUISwipeToPopScreen {
    var id: String { "details_screen" }
    
    // Настройка свайпа: только вправо, нижний экран будет виден на 30%
    var swipeToPopConfig: SUISwipeToPopConfig? {
        SUISwipeToPopConfig(direction: .right, previousScreenVisibility: 0.3)
    }
    
    // ... реализация протокола SUIScreenProtocol
}
```

Вы также можете разрешить свайп в несколько сторон одновременно (вверх/вниз/влево/вправо). В этом случае предыдущий экран будет статично находиться по центру.

## 🏗 Архитектура

Пакет строго разделен на модули внутри `Sources/`:

- `Core`: Протоколы экранов, ViewModel'ей, State Machine и DI контейнер.
- `Implementations`: Реализация стека, фабрика экранов и рендеринг (`SUINavigationContainerView`).
- `Transitions`: Дескрипторы анимаций, параметры (Opacity, Offset, Scale), модификаторы вью и стили (Fade, Slide).
- `Gestures`: Конфигурация свайпов и модификатор обработки `DragGesture`.
- `Utils`: Debug логгер и безопасные сабскрипты.

Примеры использования конкретных экранов и сборки DI контейнера находятся в папке `/Examples` в корне репозитория.

## 📄 Лицензия
Данный проект распространяется под лицензией MIT. Подробнее в файле [LICENSE](LICENSE).
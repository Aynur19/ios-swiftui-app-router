import SwiftUI

public struct SUISwipeToPopModifier: ViewModifier {
    @Environment(\.screenBounds) private var bounds
    
    @State private var lockedAxis: SUIAxis? = nil
    @State private var activeDirection: SUISwipeDirection? = nil
    @State private var isInteracting = false
    
    // ТОЧКА СТАРТА: запоминаем координаты в момент начала движения экрана
    @State private var activationPoint: CGSize = .zero
    
    let config: SUISwipeToPopConfig
    let navigator: any SUIAppNavigator
    let currentVM: any SUIScreenStateViewModel
    let previousVM: (any SUIScreenStateViewModel)?
    
    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { value in
                        guard let previousVM else { return }
                        handleChanged(value: value, previousVM: previousVM)
                    }
                    .onEnded { value in
                        guard let previousVM else { return }
                        handleEnded(value: value, currentVM: currentVM, previousVM: previousVM)
                    }
            )
    }
    
    // MARK: - Logic
    private func handleChanged(
        value: DragGesture.Value,
        previousVM: any SUIScreenStateViewModel
    ) {
        let translation = value.translation
        
        // 1. ЛОГИКА БЛОКИРОВКИ ОСИ
        lockAxis(translation: translation)
        guard let axis = lockedAxis else { return }
        
        // 2. ВЫЧИСЛЯЕМ ОТНОСИТЕЛЬНЫЙ СДВИГ
        var relativeTranslation: CGFloat = {
            if axis == .horizontal {
                return translation.width - activationPoint.width
            } else {
                return translation.height - activationPoint.height
            }
        }()
        
        // 3. ВАЛИДАЦИЯ НАПРАВЛЕНИЯ
        directionValidation(
            axis: axis,
            translation: translation,
            relativeTranslation: &relativeTranslation,
            previousVM: previousVM
        )
        
        // 4. ПРИМЕНЯЕМ СДВИГИ (С защитой от выхода за границы)
        guard let dir = activeDirection else { return }
        
        applyOffset(
            dir: dir,
            axis: axis,
            relativeTranslation: relativeTranslation,
            previousVM: previousVM
        )
    }
    
    private func lockAxis(translation: CGSize) {
        if lockedAxis == nil {
            let hasH = config.directions.contains(.left) || config.directions.contains(.right)
            let hasV = config.directions.contains(.up) || config.directions.contains(.down)
            
            if hasH && !hasV {
                // Разрешена ТОЛЬКО горизонталь -> блокируем сразу
                lockedAxis = .horizontal
            } else if !hasH && hasV {
                // Разрешена ТОЛЬКО вертикаль -> блокируем сразу
                lockedAxis = .vertical
            } else if hasH && hasV {
                // Разрешены обе оси -> ждем доминирующее движение (порог 10pt)
                if abs(translation.width) > 10 && abs(translation.width) >= abs(translation.height) {
                    lockedAxis = .horizontal
                } else if abs(translation.height) > 10 && abs(translation.height) > abs(translation.width) {
                    lockedAxis = .vertical
                }
            }
        }
    }
    
    private func directionValidation(
        axis: SUIAxis,
        translation: CGSize,
        relativeTranslation: inout CGFloat,
        previousVM: any SUIScreenStateViewModel
    ) {
        if activeDirection == nil {
            let dir = findValidDirection(translation: relativeTranslation, axis: axis)
            guard let dir else { return } // Движение не в ту сторону
            
            activeDirection = dir
            isInteracting = true
            
            // ЗАПОМИНАЕМ ТЕКУЩУЮ ПОЗИЦИЮ КАК СТАРТОВУЮ!
            activationPoint = translation
            
            // Инициализируем предыдущий экран
            previousVM.setOpacityDirectly(1.0)
            
            if config.directions.count == 1 {
                previousVM.setOffsetDirectly(calculateInitialOffset(for: dir))
            } else {
                previousVM.setOffsetDirectly(.zero)
            }
            
            // Так как мы только что зафиксировали старт, относительный сдвиг равен 0
            relativeTranslation = 0
        }
    }
    
    private func applyOffset(
        dir: SUISwipeDirection,
        axis: SUIAxis,
        relativeTranslation: CGFloat,
        previousVM: any SUIScreenStateViewModel
    ) {
        let rawOffset = convertToCGPoint(translation: relativeTranslation, axis: axis)
        let safeOffset = clampOffset(rawOffset, direction: dir)
        
        currentVM.setOffsetDirectly(safeOffset)
        
        if config.directions.count == 1 {
            let parallax = CGPoint(
                x: safeOffset.x * config.previousScreenVisibility,
                y: safeOffset.y * config.previousScreenVisibility
            )
            let initial = calculateInitialOffset(for: dir)
            
            previousVM.setOffsetDirectly(CGPoint(
                x: initial.x + parallax.x,
                y: initial.y + parallax.y
            ))
        }
    }
    
    
    private func handleEnded(
        value: DragGesture.Value,
        currentVM: any SUIScreenStateViewModel,
        previousVM: any SUIScreenStateViewModel
    ) {
        // Сброс состояний
        defer {
            lockedAxis = nil
            activeDirection = nil
            isInteracting = false
            activationPoint = .zero
        }
        
        // Если жест завершился, но экран даже не начал двигаться — просто выходим
        guard let axis = lockedAxis, let direction = activeDirection else { return }
        
        // Считаем финальный сдвиг относительно точки старта
        let finalRelativeTranslation: CGFloat
        if axis == .horizontal {
            finalRelativeTranslation = value.translation.width - activationPoint.width // <--- width
        } else {
            finalRelativeTranslation = value.translation.height - activationPoint.height // <--- height
        }
        
        let threshold = calculateThreshold()
        
        if abs(finalRelativeTranslation) > threshold {
            finishPop(currentVM: currentVM, previousVM: previousVM, direction: direction)
        } else {
            cancelPop(currentVM: currentVM, previousVM: previousVM, direction: direction)
        }
    }
    
    
    // MARK: - Helpers
    private func findValidDirection(translation: CGFloat, axis: SUIAxis) -> SUISwipeDirection? {
        guard abs(translation) > 10 else { return nil } // Порог старта 10pt
        
        switch axis {
            case .horizontal:
                if translation > 0 && config.directions.contains(.right) { return .right }
                if translation < 0 && config.directions.contains(.left) { return .left }
            case .vertical:
                if translation > 0 && config.directions.contains(.down) { return .down }
                if translation < 0 && config.directions.contains(.up) { return .up }
        }
        
        return nil
    }
    
    // Не позволяет координатам выйти за "0" в неправильную сторону
    private func clampOffset(_ offset: CGPoint, direction: SUISwipeDirection) -> CGPoint {
        var clamped = offset
        switch direction {
            case .right: clamped.x = max(0, clamped.x)
            case .left:  clamped.x = min(0, clamped.x)
            case .down:  clamped.y = max(0, clamped.y)
            case .up:    clamped.y = min(0, clamped.y)
        }
     
        return clamped
    }
    
    private func convertToCGPoint(translation: CGFloat, axis: SUIAxis) -> CGPoint {
        switch axis {
            case .horizontal: return CGPoint(x: translation, y: 0)
            case .vertical:   return CGPoint(x: 0, y: translation)
        }
    }
    
    private func calculateInitialOffset(for direction: SUISwipeDirection) -> CGPoint {
        let v = config.previousScreenVisibility
        switch direction {
            case .right: return CGPoint(x: -bounds.width * v, y: 0)
            case .left:  return CGPoint(x: bounds.width * v, y: 0)
            case .down:  return CGPoint(x: 0, y: -bounds.height * v)
            case .up:    return CGPoint(x: 0, y: bounds.height * v)
        }
    }
    
    private func calculateThreshold() -> CGFloat {
        max(bounds.width, bounds.height) * 0.2
    }
    
    private func finishPop(
        currentVM: any SUIScreenStateViewModel,
        previousVM: any SUIScreenStateViewModel,
        direction: SUISwipeDirection
    ) {
        let finalOffset: CGPoint
        switch direction {
            case .right: finalOffset = CGPoint(x: bounds.width, y: 0)
            case .left:  finalOffset = CGPoint(x: -bounds.width, y: 0)
            case .down:  finalOffset = CGPoint(x: 0, y: bounds.height)
            case .up:    finalOffset = CGPoint(x: 0, y: -bounds.height)
        }
        
        withAnimation(.easeOut(duration: 0.25)) {
            currentVM.setOffsetDirectly(finalOffset)
            previousVM.setOffsetDirectly(.zero)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [navigator] in
            navigator.popScreenSilently()
        }
    }
    
    private func cancelPop(
        currentVM: any SUIScreenStateViewModel,
        previousVM: any SUIScreenStateViewModel,
        direction: SUISwipeDirection
    ) {
        let targetPrevOffset = config.directions.count == 1 ? calculateInitialOffset(for: direction) : .zero
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentVM.setOffsetDirectly(.zero)
            previousVM.setOffsetDirectly(targetPrevOffset)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            previousVM.setOpacityDirectly(0)
        }
    }
}

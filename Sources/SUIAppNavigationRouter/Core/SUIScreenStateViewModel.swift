import SwiftUI

@MainActor
public protocol SUIScreenStateViewModel: Sendable, ObservableObject {
    var transitionState: SUIScreenTransitionState { get }   
    var state: SUIScreenState { get }
    
    func setOffsetDirectly(_ offset: CGPoint)
    func setOpacityDirectly(_ opacity: Double)
    
    func appearView(transition: SUIScreenTransition?)
    func holdView(transition: SUIScreenTransition?)
    func disappearView(transition: SUIScreenTransition?)
    func deinitView(transition: SUIScreenTransition?)
}

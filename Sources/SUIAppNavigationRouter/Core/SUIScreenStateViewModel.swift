import SwiftUI

@MainActor
public protocol SUIScreenStateViewModel: Sendable, ObservableObject {
    var transitionState: SUIScreenTransitionState { get }   
    var state: SUIScreenState { get }
    var visibilityProgress: Double { get }
    
    func setOffsetDirectly(_ offset: CGPoint)
    func setVisibilityDirectly(_ visibility: Double)
    func setStateDirectly(_ state: SUIScreenState)
    
    func appearView(transition: SUIScreenTransition?)
    func holdView(transition: SUIScreenTransition?)
    func disappearView(transition: SUIScreenTransition?)
    func deinitView(transition: SUIScreenTransition?)
}

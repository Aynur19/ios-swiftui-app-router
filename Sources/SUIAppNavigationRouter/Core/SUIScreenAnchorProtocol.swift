import SwiftUI

public protocol SUIScreenAnchorProtocol: Sendable, Hashable {
    func animationOffset(bounds: CGSize, coef: CGFloat) -> CGPoint
    func assymmetric() -> any SUIScreenAnchorProtocol
}

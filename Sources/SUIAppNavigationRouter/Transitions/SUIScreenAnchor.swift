import Foundation

public enum SUIScreenAnchor {
    case topLeft
    case topCenter
    case topRight
    case centerLeft
    case center
    case centerRight
    case bottomLeft
    case bottomCenter
    case bottomRight
    case custom(offsetCoefX: CGFloat, offsetCoefY: CGFloat)
}

extension SUIScreenAnchor: SUIScreenAnchorProtocol {
    public func animationOffset(bounds: CGSize, coef: CGFloat) -> CGPoint {
        switch self {
            case .topLeft:          CGPoint(x: -bounds.width * coef, y: -bounds.height * coef)
            case .topCenter:        CGPoint(x: 0, y: -bounds.height * coef)
            case .topRight:         CGPoint(x: bounds.width * coef, y: -bounds.height * coef)
            case .centerLeft:       CGPoint(x: -bounds.width * coef, y: 0)
            case .center:           CGPoint(x: 0, y: 0)
            case .centerRight:      CGPoint(x: bounds.width * coef, y: 0)
            case .bottomLeft:       CGPoint(x: -bounds.width * coef, y: bounds.height * coef)
            case .bottomCenter:     CGPoint(x: 0, y: bounds.height * coef)
            case .bottomRight:      CGPoint(x: bounds.width * coef, y: bounds.height * coef)
            case let .custom(offsetCoefX, offsetCoefY):
                CGPoint(
                    x: bounds.width * offsetCoefX * coef,
                    y: bounds.height * offsetCoefY * coef
                )
        }
    }
    
    public func assymmetric() -> any SUIScreenAnchorProtocol {
        switch self {
            case .topLeft:          SUIScreenAnchor.bottomRight
            case .topCenter:        SUIScreenAnchor.bottomCenter
            case .topRight:         SUIScreenAnchor.bottomLeft
            case .centerLeft:       SUIScreenAnchor.centerRight
            case .center:           SUIScreenAnchor.center
            case .centerRight:      SUIScreenAnchor.centerLeft
            case .bottomLeft:       SUIScreenAnchor.topRight
            case .bottomCenter:     SUIScreenAnchor.topCenter
            case .bottomRight:      SUIScreenAnchor.topLeft
            
            case let .custom(offsetCoefX, offsetCoefY):
                SUIScreenAnchor.custom(
                    offsetCoefX: 0 - offsetCoefX,
                    offsetCoefY: 0 - offsetCoefY
                )
        }
    }
}

import SwiftUI

extension Color {
    static var random: Color {
        Color(
            red:   Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue:  Double.random(in: 0...1),
            opacity: 1.0
        )
    }
}

import Foundation

@MainActor
public enum SUIDebugger: Sendable {
    public static var printEnabled = false
    public static var assertionFailureEnabled = false
    
    static func print(_ message: String) {
        if printEnabled {
            print(message)
        }
    }
    
    static func assertionFailure(_ message: String) {
        if assertionFailureEnabled {
            assertionFailure(message)
        }
    }
}

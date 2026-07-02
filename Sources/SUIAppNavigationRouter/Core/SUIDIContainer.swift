@MainActor
public protocol SUIDIContainer: Sendable, AnyObject {
    var navigator: any SUIAppNavigator { get }
    var screenViewFactory: any SUIScreenViewFactory { get }
}

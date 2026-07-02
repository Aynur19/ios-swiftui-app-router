@MainActor
public protocol SUIScreenViewModel {
    var navigator: (any SUIAppNavigator)? { get }
}

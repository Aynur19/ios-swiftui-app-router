import SwiftUI

public typealias SUIScreenID = String

public protocol SUIScreenProtocol: Sendable, Identifiable<SUIScreenID> {
    var id: SUIScreenID { get }
    
    @MainActor
    func screenView(viewModel: any SUIScreenViewModel) -> AnyView?
    
    @MainActor
    func screenViewModel(navigator: (any SUIAppNavigator)?) -> SUIScreenViewModel
}

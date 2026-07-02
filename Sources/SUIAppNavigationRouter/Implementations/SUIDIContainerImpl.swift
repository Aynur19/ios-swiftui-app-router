@MainActor
public final class SUIDIContainerImpl: SUIDIContainer {
    public static let shared = SUIDIContainerImpl()
    
    private init() {}
    
    public private(set) lazy var navigator: any SUIAppNavigator = {
        SUIAppNavigatorImpl(deps: self)
    }()
    
    public private(set) lazy var screenViewFactory: any SUIScreenViewFactory = {
        SUIScreenViewFactoryImpl(deps: self)
    }()
}

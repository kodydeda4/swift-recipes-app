import ApiClient
import ComposableArchitecture
import DesignSystem
import HomeFeature
import SwiftUI

@Reducer
public struct AppReducer {
  @ObservableState
  public struct State: Equatable {
    var home = Home.State()
    var sidebarDestination: SidebarDestinationTag? = .home
    var navigationSplitViewVisibility = NavigationSplitViewVisibility.all
    
    struct SidebarDestinationTag: Identifiable, Equatable, Hashable, CaseIterable {
      let id: Int
      let title: String
      let systemImage: String
      
      static let home = Self(id: 0, title: "Home", systemImage: "house")
      
      static var allCases: [Self] = [.home]
    }
    
    public init() {}
  }
  
  public enum Action: ViewAction {
    case view(View)
    case home(Home.Action)
    
    public enum View: BindableAction {
      case binding(BindingAction<State>)
    }
  }
  
  public init() {}
  
  @Dependency(\.api) var api
  
  public var body: some ReducerOf<Self> {
    BindingReducer(action: \.view)
    Scope(state: \.home, action: \.home) { Home() }
      ._printChanges()
  }
}


// MARK: - SwiftUI

@ViewAction(for: AppReducer.self)
public struct AppView: View {
  @Bindable public var store: StoreOf<AppReducer>
  
  public init(store: StoreOf<AppReducer>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationSplitView(
      columnVisibility: $store.navigationSplitViewVisibility,
      sidebar: { sidebar },
      detail: { detail }
    )
  }
  
  @MainActor private var sidebar: some View {
    List(selection: $store.sidebarDestination) {
      ForEach(AppReducer.State.SidebarDestinationTag.allCases) { value in
        NavigationLink(value: value) {
          Label(value.title, systemImage: value.systemImage)
        }
      }
    }
    .navigationTitle("Recipes")
  }
  
  @MainActor private var detail: some View {
    Group {
      switch store.sidebarDestination {
      case .home:
        HomeView(store: store.scope(state: \.home, action: \.home))
      default:
        EmptyView()
      }
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  Preview {
    AppView(store: Store(initialState: AppReducer.State()) {
      AppReducer()
    })
  }
}

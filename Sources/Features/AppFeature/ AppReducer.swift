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
    var sidebarDestinationTag: SidebarDestinationTag? = .home
    var navigationSplitViewVisibility = NavigationSplitViewVisibility.all
    
    enum SidebarDestinationTag: Equatable {
      case home
    }
    
    public init() {}
  }
  
  public enum Action: ViewAction {
    case view(View)
    case home(Home.Action)
    
    public enum View: BindableAction {
      case sidebarButtonTapped
      case binding(BindingAction<State>)
    }
  }
  
  public init() {}
  
  @Dependency(\.api) var api
  
  public var body: some ReducerOf<Self> {
    BindingReducer(action: \.view)
    Scope(state: \.home, action: \.home) { Home() }
    Reduce { state, action in
      switch action {
        
      case .view(.sidebarButtonTapped):
        switch state.navigationSplitViewVisibility {
          
        case .all:
          state.navigationSplitViewVisibility = .detailOnly
          
        case .detailOnly:
          state.navigationSplitViewVisibility = .all
          
        default:
          state.navigationSplitViewVisibility = .all
        }
        return .none
        
      default:
        return .none
      }
    }
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
    List(selection: $store.sidebarDestinationTag) {
      NavigationLink(value: AppReducer.State.SidebarDestinationTag.home) {
        Label("Home", systemImage: "house")
      }
    }
    .navigationTitle("Recipes")
    .toolbar {
      ToolbarItem(placement: .navigation) {
        Button {
          send(.sidebarButtonTapped)
        } label: {
          Image(systemName: "sidebar.leading")
        }
      }
    }
  }
  
  @MainActor private var detail: some View {
    Group {
      switch store.sidebarDestinationTag {
        
      case .home:
        HomeView(store: store.scope(state: \.home, action: \.home))
        
      default:
        EmptyView()
      }
    }
    .toolbar {
      if store.navigationSplitViewVisibility != .all {
        ToolbarItem(placement: .navigation) {
          Button {
            send(.sidebarButtonTapped)
          } label: {
            Image(systemName: "sidebar.trailing")
          }
        }
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

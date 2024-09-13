import ApiClient
import ComposableArchitecture
import DesignSystem
import MealList
import SwiftUI

@Reducer
public struct AppReducer {
  @ObservableState
  public struct State: Equatable {
    var recipes = Recipes.State()
    var destinationTag: DestinationTag? = .recipes
    
    public enum DestinationTag: String, Equatable, CaseIterable {
      case recipes = "Recipes"
    }
    
    public init() {}
  }
  
  public enum Action: ViewAction {
    case view(View)
    case recipes(Recipes.Action)
    
    public enum View: BindableAction {
      case binding(BindingAction<State>)
    }
  }
  
  public init() {}
  
  @Dependency(\.api) var api
  
  public var body: some ReducerOf<Self> {
    BindingReducer(action: \.view)
    Scope(state: \.recipes, action: \.recipes) { Recipes() }
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
      columnVisibility: .constant(.all),
      sidebar: {
        List(selection: $store.destinationTag) {
          ForEach(AppReducer.State.DestinationTag.allCases, id: \.self) { value in
            NavigationLink(value: value) {
              Text(value.rawValue.capitalized)
            }
          }
        }
        .navigationTitle("Sidebar")
      },
      content: {
        switch store.destinationTag {
        case .recipes:
          RecipesView(store: store.scope(state: \.recipes, action: \.recipes))
        case .none:
          EmptyView()
        }
      },
      detail: {
        switch store.destinationTag {
        case .recipes:
          RecipesDetailView(store: store.scope(state: \.recipes, action: \.recipes))
        case .none:
          EmptyView()
        }
      }
    )
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

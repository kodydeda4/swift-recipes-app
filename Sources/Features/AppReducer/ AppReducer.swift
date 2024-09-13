import ApiClient
import ComposableArchitecture
import DesignSystem
import MealList
import SwiftUI

@Reducer
public struct AppReducer {
  @ObservableState
  public struct State: Equatable {
    var mealCategories = IdentifiedArrayOf<ApiClient.MealCategory>()
    @Presents var destination: Destination.State?

    public init() {}
  }
  
  public enum Action: ViewAction {
    case view(View)
    case destination(PresentationAction<Destination.Action>)
    case fetchAllMealCategoriesResponse(Result<[ApiClient.MealCategory], Error>)
    
    public enum View {
      case onAppear
      case navigateToMealList(category: ApiClient.MealCategory)
    }
  }
  
  public init() {}
  
  @Dependency(\.api) var api
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case .view(.onAppear):
        return .run { send in
          await send(.fetchAllMealCategoriesResponse(Result {
            struct Response: Codable {
              let categories: [ApiClient.MealCategory]
            }
            let response: Response = try await self.api.request(.fetchAllMealCategories())
            return response.categories
          }))
        }
        
      case let .view(.navigateToMealList(category: value)):
        state.destination = .mealList(MealList.State(category: value))
        return .none

      case let .fetchAllMealCategoriesResponse(.success(value)):
        state.mealCategories = .init(uniqueElements: value)
        return .none
        
      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
  
  @Reducer(state: .equatable)
  public enum Destination {
    case mealList(MealList)
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
    NavigationStack {
      List {
        ForEach(store.mealCategories) { value in
          Button {
            send(.navigateToMealList(category: value))
          } label: {
            Text(value.strCategory)
          }
        }
      }
      .onAppear { send(.onAppear) }
      .appFontNavigationTitle("App")
      .navigationDestination(item: $store.scope(
        state: \.destination?.mealList,
        action: \.destination.mealList
      )) { store in
        MealListView(store: store)
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

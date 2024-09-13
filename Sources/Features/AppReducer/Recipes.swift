import ApiClient
import ComposableArchitecture
import DesignSystem
import MealList
import SwiftUI

@Reducer
public struct Recipes {
  @ObservableState
  public struct State: Equatable {
    @Presents var details: MealList.State?
    var mealCategories = IdentifiedArrayOf<ApiClient.MealCategory>()
    
    public init() {}
  }
  
  public enum Action: ViewAction {
    case view(View)
    case details(PresentationAction<MealList.Action>)
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
            struct Response: Codable { let categories: [ApiClient.MealCategory] }
            let response: Response = try await self.api.request(.fetchAllMealCategories())
            return response.categories
          }))
        }
        
      case let .view(.navigateToMealList(category: value)):
        state.details = MealList.State(category: value)
        return .none
        
      case let .fetchAllMealCategoriesResponse(.success(value)):
        state.mealCategories = .init(uniqueElements: value)
        return .none
        
      default:
        return .none
      }
    }
    .ifLet(\.$details, action: \.details) { MealList() }
  }
}

@ViewAction(for: Recipes.self)
public struct RecipesView: View {
  @Bindable public var store: StoreOf<Recipes>
  
  public init(store: StoreOf<Recipes>) {
    self.store = store
  }
  
  public var body: some View {
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
    .navigationTitle("Recipes")
  }
}

@ViewAction(for: Recipes.self)
public struct RecipesDetailView: View {
  @Bindable public var store: StoreOf<Recipes>
  
  public init(store: StoreOf<Recipes>) {
    self.store = store
  }
  
  public var body: some View {
    Group {
      if let store = store.scope(state: \.details, action: \.details.presented) {
        MealListView(store: store)
      }
    }
  }
}

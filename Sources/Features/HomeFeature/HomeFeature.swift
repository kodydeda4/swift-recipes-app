import ApiClient
import ComposableArchitecture
import DesignSystem
import MealDetailsFeature
import SwiftUI

@Reducer
public struct Home {
  @ObservableState
  public struct State: Equatable {
    @Presents var destination: Destination.State?
    var mealCategory: ApiClient.MealCategory?
    var mealCategories = IdentifiedArrayOf<ApiClient.MealCategory>()
    var rows = IdentifiedArrayOf<Row>()
    var inFlight = false
    var error: String?

    struct Row: Identifiable, Equatable {
      var id: ApiClient.Meal.ID { meal.id }
      let meal: ApiClient.Meal
      var inFlight = false
    }

    public init() {}
  }
  
  public enum Action: ViewAction {
    case view(View)
    case destination(PresentationAction<Destination.Action>)
    case fetchAllMealCategoriesResponse(Result<[ApiClient.MealCategory], Error>)
    case fetchMeals(ApiClient.MealCategory)
    case fetchMealsResponse(Result<[ApiClient.Meal], Error>)
    case fetchMealDetailsResponse(ApiClient.Meal.ID, Result<[ApiClient.MealDetails], Error>)
    
    public enum View {
      case onAppear
      case mealCategoryButtonTapped(ApiClient.MealCategory)
      case navigateToMealDetails(id: ApiClient.Meal.ID)
    }
  }
  
  public init() {}
  
  @Dependency(\.api) var api
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .fetchMealsResponse(result):
        state.inFlight = false
        switch result {
          
        case let .success(value):
          state.rows = IdentifiedArrayOf(uniqueElements: value.map { State.Row(meal: $0) })
          return .none
          
        case let .failure(error):
          state.error = error.localizedDescription
          return .none
        }
        
      case let .fetchMealDetailsResponse(id, result):
        state.rows[id: id]?.inFlight = false
        
        switch result {
          
        case let .success(value):
          if let first = value.first {
            state.destination = .mealDetails(MealDetails.State(meal: first))
          }
          return .none
          
        case let .failure(error):
          state.error = error.localizedDescription
          return .none
        }
        
      case let .fetchAllMealCategoriesResponse(response):
        switch response {
          
        case let .success(value):
          state.mealCategories = .init(uniqueElements: value)
          return .none
          
        case let .failure(error):
          state.error = error.localizedDescription
          return .none
        }
        
      case let .fetchMeals(mealCategory):
        return .run { send in
          await send(.fetchMealsResponse(Result {
            struct Response: Codable { let meals: [ApiClient.Meal] }
            let response: Response = try await api.request(.fetchAllMeals(category: mealCategory))
            return response.meals
          }))
        }

      case let .view(action):
        switch action {
          
        case .onAppear:
          state.inFlight = true
          return .run { send in
            await send(.fetchAllMealCategoriesResponse(Result {
              struct Response: Codable { let categories: [ApiClient.MealCategory] }
              let response: Response = try await api.request(.fetchAllMealCategories())
              return response.categories
            }))
          }

        case let .navigateToMealDetails(id):
          state.rows[id: id]?.inFlight = true
          return .run { send in
            await send(.fetchMealDetailsResponse(id, Result {
              struct Response: Codable { let meals: [ApiClient.MealDetails] }
              let response: Response = try await api.request(.fetchAllMealDetailsBy(by: id))
              return response.meals
            }))
          }
          
        case let .mealCategoryButtonTapped(value):
          state.mealCategory = value
          return .send(.fetchMeals(value))
        }
        
      default:
        return .none
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
  
  @Reducer(state: .equatable)
  public enum Destination {
    case mealDetails(MealDetails)
  }
}

// MARK: - SwiftUI

@ViewAction(for: Home.self)
public struct HomeView: View {
  @Bindable public var store: StoreOf<Home>
  
  public init(store: StoreOf<Home>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationStack {
      ScrollView {
        Section("Categories") {
          mealCategoriesView.padding(.horizontal)
        }
        if !store.rows.isEmpty {
          Section("Categories") {
            mealsView
          }
        }
      }
      .onAppear { send(.onAppear) }
      .navigationTitle("Home")
      .navigationDestination(item: $store.scope(
        state: \.destination?.mealDetails,
        action: \.destination.mealDetails
      )) { store in
        MealDetailsView(store: store)
      }
    }
  }
  
  @MainActor private var mealCategoriesView: some View {
    LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 4)) {
      ForEach(store.mealCategories) { value in
        Button {
          send(.mealCategoryButtonTapped(value))
        } label: {
          Text(value.strCategory)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }
  }
  
  @MainActor private var mealsView: some View {
    LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 4)) {
      ForEach(store.rows) { value in
        Button {
          send(.navigateToMealDetails(id: value.id))
        } label: {
          Text(value.meal.strMeal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  Preview {
    HomeView(store: Store(initialState: Home.State()) {
      Home()
    })
  }
}

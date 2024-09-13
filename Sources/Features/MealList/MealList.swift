import ApiClient
import ComposableArchitecture
import DesignSystem
import MealDetails
import SwiftUI

@Reducer
public struct MealList {
  @ObservableState
  public struct State: Equatable {
    let category: ApiClient.MealCategory
    var rows = IdentifiedArrayOf<Row>()
    var inFlight = false
    var error: String?
    @Presents var destination: Destination.State?
    
    struct Row: Identifiable, Equatable {
      var id: ApiClient.Meal.ID { meal.id }
      let meal: ApiClient.Meal
      var inFlight = false
    }
    
    public init(category: ApiClient.MealCategory) {
      self.category = category
    }
  }
  
  public enum Action: ViewAction {
    case view(View)
    case destination(PresentationAction<Destination.Action>)
    case fetchMealsResponse(Result<[ApiClient.Meal], Error>)
    case fetchMealDetailsResponse(ApiClient.Meal.ID, Result<[ApiClient.MealDetails], Error>)
    
    public enum View {
      case task
      case cancelButtonTapped
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
        
      case let .view(action):
        switch action {
          
        case .task:
          state.inFlight = true
          return .run { [category = state.category] send in
            await send(.fetchMealsResponse(Result {
              struct Response: Codable { let meals: [ApiClient.Meal] }
              let response: Response = try await api.request(.fetchAllMeals(category: category))
              return response.meals
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
        
          //@DEDA
        case .cancelButtonTapped:
          state.destination = .none
          return .none
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

@ViewAction(for: MealList.self)
public struct MealListView: View {
  @Bindable public var store: StoreOf<MealList>
  
  public init(store: StoreOf<MealList>) {
    self.store = store
  }
  
  public var body: some View {
    Group {
      if store.inFlight {
        ProgressView()
      } else if let error = store.error {
        errorView(error)
      } else {
        list
      }
    }
    .task { await send(.task).finish() }
    .navigationTitle(store.category.strCategory.appending("s"))
    .navigationBarTitleDisplayMode(.inline)
    .sheet(item: $store.scope(
      state: \.destination?.mealDetails,
      action: \.destination.mealDetails
    )) { store in
      NavigationStack {
        MealDetailsView(store: store).toolbar {
          Button("Cancel") {
            send(.cancelButtonTapped)
          }
        }
      }
    }
  }
  
  @MainActor private func errorView(_ error: String) -> some View {
    Text(error)
  }

  @MainActor private var list: some View {
    List {
      ForEach(store.rows) { row in
        rowView(row)
          .listRowSeparator(.hidden)
      }
    }
    .listStyle(.plain)
  }
  
  @MainActor private func rowView(_ row: MealList.State.Row) -> some View {
    Button(action: { send(.navigateToMealDetails(id: row.id)) }) {
      Text(row.meal.strMeal)
    }
  }
}


// MARK: - SwiftUI Previews

#Preview {
  Preview {
    NavigationStack {
      MealListView(store: Store(initialState: MealList.State(
        category: .previewValue
      )) {
        MealList()
      })
    }
  }
}

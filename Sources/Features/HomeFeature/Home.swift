import ApiClient
import ComposableArchitecture
import DesignSystem
import MealDetailsFeature
import SwiftUI
import SwiftUIHelpers

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
        if case let .success(value) = result {
          state.rows = IdentifiedArrayOf(uniqueElements: value.map { State.Row(meal: $0) })
        }
        return .none
        
      case let .fetchMealDetailsResponse(id, result):
        state.rows[id: id]?.inFlight = false
        if case let .success(value) = result {
          state.destination = value.first.flatMap {
            .mealDetails(MealDetails.State(meal: $0))
          }
        }
        return .none
        
      case let .fetchAllMealCategoriesResponse(result):
        if case let .success(value) = result {
          state.mealCategories = .init(uniqueElements: value)
        }
        return .none
        
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
          
        case let .mealCategoryButtonTapped(category):
          state.mealCategory = category
          return .run { send in
            await send(.fetchMealsResponse(Result {
              struct Response: Codable { let meals: [ApiClient.Meal] }
              let response: Response = try await api.request(.fetchAllMeals(in: category))
              return response.meals
            }))
          }
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
      VStack(spacing: 0) {
        Section {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              ForEach(store.mealCategories, content: mealCategoryView)
            }
            .padding([.leading, .vertical])
          }
        }

        if !store.rows.isEmpty {
          Section {
            ScrollView(showsIndicators: false) {
              LazyVGrid(columns: .init(repeating: .init(.flexible()), count: 6)) {
                ForEach(store.rows, content: rowView)
              }
            }
            .padding([.horizontal, .top])
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
  
  @MainActor private func mealCategoryView(value: ApiClient.MealCategory) -> some View {
    Button {
      send(.mealCategoryButtonTapped(value))
    } label: {
      Text(value.strCategory)
        .frame(maxWidth: .infinity)
    }
    .if(value == store.mealCategory) { view in
      view.tint(.accentColor)
    }
  }
  
  @MainActor private func rowView(value: Home.State.Row) -> some View {
    Button {
      send(.navigateToMealDetails(id: value.id))
    } label: {
      VStack(alignment: .leading) {
        AsyncImage(url: URL(string: value.meal.strMealThumb)) {
          $0.resizable().scaledToFill()
        } placeholder: {
          ProgressView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .frame(width: 120, height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity)

        Text(value.meal.strMeal)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .lineLimit(2)
          .frame(height: 60)
        
      }
      .padding(8)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .buttonBorderShape(.roundedRectangle)
  }
}

// MARK: - SwiftUI Previews

struct PreviewView: View {
  @Bindable var store = Store(initialState: Home.State()) {
    Home()
  }
  
  var body: some View {
    Preview {
      HomeView(store: store).onAppear {
        store.send(.view(.mealCategoryButtonTapped(.previewValue)))
      }
    }
  }
}

#Preview {
  PreviewView()
}

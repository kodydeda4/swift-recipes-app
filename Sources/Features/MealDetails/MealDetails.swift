import ApiClient
import ComposableArchitecture
import DesignSystem
import SwiftUI

@Reducer
public struct MealDetails {
  @ObservableState
  public struct State: Equatable {
    let meal: ApiClient.MealDetails
    
    public init(meal: ApiClient.MealDetails) {
      self.meal = meal
    }
  }
  
  public enum Action: ViewAction {
    case view(View)
    
    public enum View {
      case task
    }
  }
  
  public init() {}
  
  @Dependency(\.api) var api
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
        case .task:
          print(state.meal)
          return .none
        }
      }
    }
  }
}

// MARK: - SwiftUI

@ViewAction(for: MealDetails.self)
public struct MealDetailsView: View {
  @Bindable public var store: StoreOf<MealDetails>
  
  public init(store: StoreOf<MealDetails>) {
    self.store = store
  }
  
  public var body: some View {
    List {
      Section {
        AsyncImage(url: URL(string: store.meal.strMealThumb)) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipped()
            .background { Color.black }

        } placeholder: {
          ProgressView()
            .frame(height: 150)
            .frame(maxWidth: .infinity)
        }
      }
      .listRowSeparator(.hidden, edges: .top)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      .overlay {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
          .strokeBorder()
          .foregroundColor(Color(.systemGray4))
      }

      Section {
        DisclosureGroup {
          ForEach(store.meal.ingredientMeasures) { value in
            HStack {
              Text(value.strMeasure)
              Text(value.strIngredient)
            }
            .appFont(.body)
          }
        } label: {
          Text("🛒 Ingredients")
            .appFont(.body, .semibold)
        }
      }
      Section {
        DisclosureGroup {
          Text(store.meal.strInstructions)
            .appFont(.body)
        } label: {
          Text("📖 Instructions")
            .appFont(.body, .semibold)
        }
      }
    }
    .appFontNavigationTitle(store.meal.strMeal)
    .listStyle(.plain)
    .task { await send(.task).finish() }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  Preview {
    NavigationStack {
      MealDetailsView(store: Store(initialState: MealDetails.State(
        meal: .previewValue
      )) {
        MealDetails()
      })
    }
  }
}

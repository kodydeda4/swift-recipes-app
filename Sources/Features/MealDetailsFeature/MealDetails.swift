import ApiClient
import ComposableArchitecture
import DesignSystem
import SwiftUI

@Reducer
public struct MealDetails {
  @ObservableState
  public struct State: Equatable {
    let meal: ApiClient.MealDetails
    var tab = Tab.instructions
    
    public enum Tab: String, Identifiable, Equatable, CustomStringConvertible, CaseIterable {
      public var id: Self { self }
      public var description: String { self.rawValue.capitalized }
      case instructions
      case ingredients
    }
    
    init(
      meal: ApiClient.MealDetails,
      tab: Tab = Tab.instructions
    ) {
      self.meal = meal
      self.tab = tab
    }
  }
  
  public enum Action: ViewAction {
    case view(View)
    
    public enum View: BindableAction {
      case task
      case binding(BindingAction<State>)
    }
  }
  
  public init() {}
  
  @Dependency(\.api) var api
  
  public var body: some ReducerOf<Self> {
    BindingReducer(action: \.view)
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
        case .task:
          print(state.meal)
          return .none
          
        case .binding:
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
    ScrollView {
      HStack {
        content
        image
      }
    }
    .navigationTitle(store.meal.strMeal)
    .listStyle(.plain)
    .task { await send(.task).finish() }
    .toolbar {
      Menu {
        Button("Save") {
          
        }
      } label: {
        Image(systemName: "ellipsis")
      }
    }
  }
  
  @MainActor private var content: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(store.meal.strMeal)
        .font(.extraLargeTitle)
        .padding(.bottom, 8)

      Text(store.tab.description)
        .font(.largeTitle)
        .padding(.bottom)

      TabView(selection: $store.tab) {
        VStack {
          Text(store.meal.strInstructions)
          Spacer()
        }
        .tag(MealDetails.State.Tab.instructions)
        .tabItem { Text("Instructions") }
        
        VStack(alignment: .leading) {
          ForEach(store.meal.ingredientMeasures) { value in
            HStack(spacing: 0) {
              Text("- ")
              Text(value.strMeasure.capitalized.appending(" "))
              Text(value.strIngredient)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
          Spacer()
        }
        .tag(MealDetails.State.Tab.ingredients)
        .tabItem { Text("Ingredients") }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      
      Spacer()

      Picker("@DEDA", selection: $store.tab) {
        ForEach(MealDetails.State.Tab.allCases) { value in
          Text(value.description).tag(value)
        }
      }
      .pickerStyle(.segmented)
      .frame(width: 300)
      .frame(maxWidth: .infinity)

    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.horizontal, 32)
  }

  @MainActor private var image: some View {
    Section {
      AsyncImage(url: URL(string: store.meal.strMealThumb)) { image in
        image
          .resizable()
          .scaledToFill()
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
    .padding(.horizontal, 64)
  }
}

// MARK: - SwiftUI Previews

#Preview {
  Preview {
    NavigationStack {
      MealDetailsView(store: Store(initialState: MealDetails.State(
        meal: .previewValue,
        tab: .ingredients
      )) {
        MealDetails()
      })
    }
  }
}

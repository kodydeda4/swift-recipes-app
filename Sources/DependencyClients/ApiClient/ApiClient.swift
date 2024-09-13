import ComposableArchitecture
import DependenciesMacros
import Foundation
import MemberwiseInit
import Tagged
import Combine

@DependencyClient
public struct ApiClient: DependencyKey {
  public var fetchAllMealCategories: @Sendable () async throws -> [MealCategory]
  public var fetchAllMeals: @Sendable (MealCategory) async throws -> [Meal]
  public var fetchMealDetailsById: (Meal.ID) async throws -> [MealDetails]
  
  public static var liveValue: Self {
    let api = ApiActor()
    
    return Self(
      fetchAllMealCategories: {
        struct Response: Codable {
          let categories: [ApiClient.MealCategory]
        }
        let response: Response = try await api.request(
          "https://www.themealdb.com/api/json/v1/1/categories.php"
        )
        return response.categories
      },
      fetchAllMeals: { category in
        struct Response: Codable {
          let meals: [ApiClient.Meal]
        }
        let response: Response = try await api.request(
          "https://themealdb.com/api/json/v1/1/filter.php?c=\(category.strCategory)"
        )
        return response.meals
      },
      fetchMealDetailsById: { id in
        struct Response: Codable {
          let meals: [ApiClient.MealDetails]
        }
        let response: Response = try await api.request(
          "https://themealdb.com/api/json/v1/1/lookup.php?i=\(id)"
        )
        return response.meals
      }
    )
  }
}

final actor ApiActor {
  @Sendable func request<T: Decodable>(_ url: String) async throws -> T {
    guard let url = URL(string: url) else {
      throw URLError(.badURL)
    }
    
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // Check for valid HTTP response
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode)
    else {
      throw URLError(.badServerResponse)
    }
    
    // Decode the JSON data to the specified type
    do {
      let response = try JSONDecoder().decode(T.self, from: data)
      return response
    } catch {
      print("Failed to decode type.")
      throw error
    }
  }
}

extension DependencyValues {
  public var api: ApiClient {
    get { self[ApiClient.self] }
    set { self[ApiClient.self] = newValue }
  }
}

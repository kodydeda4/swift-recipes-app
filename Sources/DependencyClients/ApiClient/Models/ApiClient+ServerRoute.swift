import Foundation

extension ApiClient {
  public struct ServerRoute {
    public let url: String
  }
}

extension ApiClient.ServerRoute {
  public static func fetchAllMealCategories() -> Self {
    Self(url: "https://www.themealdb.com/api/json/v1/1/categories.php")
  }
  public static func fetchAllMeals(in category: ApiClient.MealCategory) -> Self {
    Self(url: "https://themealdb.com/api/json/v1/1/filter.php?c=\(category.strCategory)")
  }
  public static func fetchAllMealDetailsBy(by id: ApiClient.Meal.ID) -> Self {
    Self(url: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(id)")
  }
}

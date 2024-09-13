import Foundation

extension ApiClient {
  public struct Meal: Codable, Equatable {
    public let idMeal: String
    public let strMeal: String
    public let strMealThumb: String
  }
}

// MARK: -  Extensions

extension ApiClient.Meal: Identifiable {
  public var id: String { idMeal }
}

extension ApiClient.Meal {
  public static let previewValue = Self(
    idMeal: "53049",
    strMeal: "Apam balik",
    strMealThumb: "https://www.themealdb.com/images/media/meals/adxcbq1619787919.jpg"
  )
}

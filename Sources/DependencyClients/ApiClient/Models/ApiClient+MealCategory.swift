import Foundation

extension ApiClient {
  public struct MealCategory: Equatable, Codable {
    public let idCategory: String
    public let strCategory: String
    public let strCategoryThumb: URL
    public let strCategoryDescription: String
  }
}

// MARK: -  Extensions

extension ApiClient.MealCategory: Identifiable {
  public var id: String { idCategory }
}

extension ApiClient.MealCategory {
  public static var previewValue = Self(
    idCategory: "3",
    strCategory: "Dessert",
    strCategoryThumb: URL(string: "https://www.themealdb.com/images/category/dessert.png")!,
    strCategoryDescription: "Dessert is a course that concludes a meal. The course usually consists of sweet foods, such as confections dishes or fruit, and possibly a beverage such as dessert wine or liqueur, however in the United States it may include coffee, cheeses, nuts, or other savory items regarded as a separate course elsewhere. In some parts of the world, such as much of central and western Africa, and most parts of China, there is no tradition of a dessert course to conclude a meal.\r\n\r\nThe term dessert can apply to many confections, such as biscuits, cakes, cookies, custards, gelatins, ice creams, pastries, pies, puddings, and sweet soups, and tarts. Fruit is also commonly found in dessert courses because of its naturally occurring sweetness. Some cultures sweeten foods that are more commonly savory to create desserts."
  )
}

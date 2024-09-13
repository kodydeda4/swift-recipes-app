import Foundation

public extension ApiClient {
  struct MealDetails: Equatable {
    public let idMeal: String
    public let strMeal: String
    public let strInstructions: String
    public let strMealThumb: String
    public let ingredientMeasures: [IngredientMeasures]
    
    public struct IngredientMeasures: Identifiable, Codable, Equatable {
      public let id: Int
      public var strMeasure: String
      public var strIngredient: String
    }
  }
}

// MARK: -  Extensions

extension ApiClient.MealDetails: Identifiable {
  public var id: String { idMeal }
}

public extension ApiClient.MealDetails {
  static let previewValue = ApiClient.MealDetails(
    idMeal: "52855",
    strMeal: "Banana Pancakes",
    strInstructions: "In a bowl, mash the banana with a fork until it resembles a thick purée. Stir in the eggs, baking powder and vanilla.\r\nHeat a large non-stick frying pan or pancake pan over a medium heat and brush with half the oil. Using half the batter, spoon two pancakes into the pan, cook for 1-2 mins each side, then tip onto a plate. Repeat the process with the remaining oil and batter. Top the pancakes with the pecans and raspberries.",
    strMealThumb: "https://www.themealdb.com/images/media/meals/sywswr1511383814.jpg",
    ingredientMeasures: [
      .init(id: 0, strMeasure: "1 large", strIngredient: "Banana"),
      .init(id: 1, strMeasure: "2 medium", strIngredient: "Eggs")
    ]
  )
}

/// Custom `Codable` conformance to dynamically parse and combine any number of `strIngredientN` and `strMeasureN` keys into a unified `ingredientMeasures` property.
extension ApiClient.MealDetails: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
    
    // 1. Decode static properties.
    idMeal = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "idMeal")!)
    strMeal = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "strMeal")!)
    strInstructions = try container.decode(
      String.self,
      forKey: DynamicCodingKeys(stringValue: "strInstructions")!
    )
    strMealThumb = try container.decode(
      String.self,
      forKey: DynamicCodingKeys(stringValue: "strMealThumb")!
    )
    
    // 2. Decode dynamic properties.
    self.ingredientMeasures = {
      let strIngredients = container.allKeys
        .filter { $0.stringValue.hasPrefix("strIngredient") }
        .compactMap {
          try? container.decodeIfPresent(String.self, forKey: $0)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        .filter { !$0.isEmpty }
      
      let strMeasures = container.allKeys
        .filter { $0.stringValue.hasPrefix("strMeasure") }
        .compactMap {
          try? container.decodeIfPresent(String.self, forKey: $0)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        .filter { !$0.isEmpty }
      
      return zip(strMeasures, strIngredients).reduce(
        into: [ApiClient.MealDetails.IngredientMeasures]()
      ) { array, element in
        array.append(ApiClient.MealDetails.IngredientMeasures(
          id: array.count,
          strMeasure: element.0,
          strIngredient: element.1
        ))
      }
    }()
    
    /// Dynamic coding keys to allow iteration over all keys
    struct DynamicCodingKeys: CodingKey {
      var stringValue: String
      init?(stringValue: String) {
        self.stringValue = stringValue
      }
      
      var intValue: Int?
      init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
      }
    }
  }
}

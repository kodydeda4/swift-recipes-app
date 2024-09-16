import Combine
import ComposableArchitecture
import DependenciesMacros
import Foundation
import MemberwiseInit
import Tagged

extension ApiClient: DependencyKey {
  public static var liveValue: Self {
    return Self(
      apiRequest: { route in
        guard let url = URL(string: route.url) else {
          throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Check for valid HTTP response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode)
        else {
          throw URLError(.badServerResponse)
        }
        
        return (data, httpResponse)
      }
    )
  }
}

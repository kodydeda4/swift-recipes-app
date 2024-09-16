import Combine
import ComposableArchitecture
import DependenciesMacros
import Foundation
import MemberwiseInit
import Tagged

@DependencyClient
public struct ApiClient: Sendable {
  public var apiRequest: @Sendable (ServerRoute) async throws -> (Data, HTTPURLResponse)
}

public extension ApiClient {
  @Sendable func request<T: Decodable>(_ route: ServerRoute) async throws -> T {
    do {
      let (data, _) = try await self.apiRequest(route)
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      let error = error
      print(error.localizedDescription)
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

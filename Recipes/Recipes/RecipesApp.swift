import AppReducer
import ComposableArchitecture
import DesignSystem
import SwiftUI

@main
struct RecipesApp: App {
  var body: some Scene {
    WindowGroup {
      if !_XCTIsTesting {
        AppView(store: Store(initialState: AppReducer.State()) {
          AppReducer()
        })
      }
    }
  }
}

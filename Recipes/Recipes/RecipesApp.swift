import AppReducer
import ComposableArchitecture
import DesignSystem
import SwiftUI

@main
struct RecipesApp: App {
  init() {
    DesignSystem.registerFonts()
  }
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

import SwiftUI
import ComposableArchitecture
import DesignSystem
import AppReducer

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

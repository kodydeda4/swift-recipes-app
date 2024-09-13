import SwiftUI

/// SwiftUI Preview Helper.
public struct Preview<Content:View>: View {
  let content: () -> Content

  public init(content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    Group {
      content()
    }
    .accentColor(.prRed)
    .registerFonts()
  }
}

private extension View {
  /// Attach this to any Xcode Preview's view to have custom fonts displayed.
  func registerFonts() -> some View {
    DesignSystem.registerFonts()
    return self
  }
}

#Preview {
  Preview {
    NavigationStack {
      Text("Hello World!")
        .appFont(.body)
        .foregroundColor(.accentColor)
    }
  }
}

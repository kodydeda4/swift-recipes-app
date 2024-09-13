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
    .accentColor(.appRed)
  }
}

#Preview {
  Preview {
    NavigationStack {
      Text("Hello World!")
        .foregroundColor(.accentColor)
    }
  }
}

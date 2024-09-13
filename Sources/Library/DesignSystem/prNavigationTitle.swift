import SwiftUI

extension View {
  public func appFontNavigationTitle(
    _ title: String,
    hidden: Bool = false
  ) -> some View {
    self
      .navigationTitle("")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text(!hidden ? title : "")
            .appFont(.body, .semibold)
        }
      }
  }
}

#Preview {
  Preview {
    NavigationStack {
      VStack {
        NavigationLink("Detail") {
          Text("Detail View")
            .appFont(.body)
        }
        .appFont(.body)
      }
      .appFontNavigationTitle("Title")
    }
  }
}

import SwiftUI

public struct RoundedRectangleButtonStyle: ButtonStyle {
  public var inFlight = false
  public var foregroundColor = Color.white
  public var backgroundColor = Color.accentColor
  public var radius = CGFloat(8)
  public var onPress: (() -> Void)? = {}

  public init(
    inFlight: Bool = false,
    foregroundColor: SwiftUI.Color = Color.white,
    backgroundColor: SwiftUI.Color = Color.accentColor,
    radius: CGFloat = CGFloat(8),
    onPress: (() -> Void)? = nil
  ) {
    self.inFlight = inFlight
    self.foregroundColor = foregroundColor
    self.backgroundColor = backgroundColor
    self.radius = radius
    self.onPress = onPress
  }


  public func makeBody(configuration: Self.Configuration) -> some View {
    Group {
      if inFlight {
        ProgressView()
          .tint(foregroundColor)
      } else {
        configuration.label
      }
    }
    .appFont(.body, .semibold)
    .foregroundColor(foregroundColor)
    .frame(height: 8*3)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity)
    .background {
      backgroundColor.overlay {
        Color.black.opacity(configuration.isPressed ? 0.25 : 0)
      }
    }
    .clipShape(RoundedRectangle(
      cornerRadius: radius,
      style: .continuous
    ))
    .animation(.default, value: configuration.isPressed)
    .onChange(of: configuration.isPressed) {
      if configuration.isPressed, let onPress {
        onPress()
      }
    }
  }
}


// MARK: - SwiftUI Previews

struct Button_RoundedRectangleButtonStyle_Previews: PreviewProvider {
  static var previews: some View {
    Button("Click Me") {

    }
    .buttonStyle(RoundedRectangleButtonStyle())
    .padding()
  }
}

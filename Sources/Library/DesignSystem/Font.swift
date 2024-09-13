import SwiftUI

public func registerFonts() {
  return [String]([
    "Montserrat-Regular",
    "Montserrat-Medium",
    "Montserrat-Bold",
    "Montserrat-SemiBold",
    "Montserrat-Light",
    "Montserrat-Italic",
    "Montserrat-Bold"
  ])
  .compactMap {
    Bundle.designSystem.url(forResource: $0, withExtension: "ttf")
  }
  .forEach {
    CTFontManagerRegisterFontsForURL($0 as CFURL, .process, nil)
  }
}
public extension View {
  func appFont(
    _ textStyle: Font.TextStyle,
    _ weight: Font.Weight? = nil
  ) -> some View {
    modifier(AppFontStyleModifier(textStyle: textStyle, weight: weight))
  }

  func appFont(
    _ size: CGFloat,
    _ weight: Font.Weight = .regular
  ) -> some View {
    modifier(AppFontSizeModifier(size: size, weight: weight))
  }
}

// MARK: - Private Helpers

private let appFontMaker = MontserratFontMaker()

private protocol AppFontMaking {
  func make(
    _ textStyle: Font.TextStyle,
    weight: Font.Weight?,
    allowDynamicType: Bool
  ) -> Font

  func make(
    _ size: CGFloat,
    weight: Font.Weight,
    allowDynamicType: Bool
  ) -> Font
}

private extension AppFontMaking {
  // Apple does quite a few clever things with their font,
  // including user changable dynamicType sizing
  // We'd like to capture as much of that behavior as possible
  // https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/

  func preferedUIFont(for textStyle: Font.TextStyle) -> UIFont {
    let uiTextStyle: UIFont.TextStyle = {
      switch textStyle {
      case .largeTitle: return .largeTitle
      case .title: return .title1
      case .title2: return .title2
      case .title3: return .title3
      case .headline: return .headline
      case .subheadline: return .subheadline
      case .body: return .body
      case .callout: return .callout
      case .footnote: return .footnote
      case .caption: return .caption1
      case .caption2: return .caption2
      @unknown default:
        //        Loggers.default.error("AppFontMaking.preferredUIFont unknown textStyle:\(textStyle)")
        return .body
      }
    }()

    return .preferredFont(forTextStyle: uiTextStyle)
  }

  func fontWeight(for textStyle: Font.TextStyle) -> Font.Weight {
    switch textStyle {
    case .body,
         .callout,
         .caption,
         .caption2,
         .footnote,
         .largeTitle,
         .subheadline,
         .title,
         .title2,
         .title3:
      return .regular
    case .headline:
      return .semibold
    @unknown default:
      //      Loggers.default.error("AppFontMaking.fontWeight(for:) unknown textStyle: \(textStyle)")
      return .regular
    }
  }

  //
  //  https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
  //
  //  Large (Default)
  //
  //  Style      Weight      Size  Leading (points)
  // -----      --------    ----  -------
  //  Large Title Regular    34    41
  //  Title 1    Regular     28    34
  //  Title 2    Regular     22    28
  //  Title 3    Regular     20    25
  //  Headline   Semi-Bold   17    22
  //  Body       Regular     17    22
  //  Callout    Regular     16    21
  //  Subhead    Regular     15    20
  //  Footnote   Regular     13    18
  //  Caption 1  Regular     12    16
  //  Caption 2  Regular     11    13
  //
  func fontSizeFixed(for textStyle: Font.TextStyle) -> CGFloat {
    let fontSize: CGFloat
    switch textStyle {
    case .largeTitle: fontSize = 34
    case .title: fontSize = 28
    case .title2: fontSize = 22
    case .title3: fontSize = 20
    case .headline: fontSize = 17
    case .body: fontSize = 17
    case .callout: fontSize = 16
    case .subheadline: fontSize = 15
    case .footnote: fontSize = 13
    case .caption: fontSize = 12
    case .caption2: fontSize = 11
    @unknown default: fontSize = 17
    }

    return fontSize
  }
}

//
//  https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/
//
//  Large (Default)
//
//  Style      Weight      Size  Leading (points)
// -----      --------    ----  -------
//  Large Title Regular    34    41
//  Title 1    Regular     28    34
//  Title 2    Regular     22    28
//  Title 3    Regular     20    25
//  Headline   Semi-Bold   17    22
//  Body       Regular     17    22
//  Callout    Regular     16    21
//  Subhead    Regular     15    20
//  Footnote   Regular     13    18
//  Caption 1  Regular     12    16
//  Caption 2  Regular     11    13
//
private struct AppFontStyleModifier: ViewModifier {
  let textStyle: Font.TextStyle
  let weight: Font.Weight?

  func body(content: Content) -> some View {
    content
      .font(appFontMaker.make(
        textStyle,
        weight: weight,
        allowDynamicType: false
      ))
  }
}

private struct AppFontSizeModifier: ViewModifier {
  let size: CGFloat
  let weight: Font.Weight

  func body(content: Content) -> some View {
    content
      .font(appFontMaker.make(
        size,
        weight: weight,
        allowDynamicType: false
      ))
  }
}

private struct SystemFontMaker: AppFontMaking {
  func make(
    _ textStyle: Font.TextStyle,
    weight: Font.Weight?,
    allowDynamicType _: Bool /* ignored for sysFont */
  ) -> Font {
    weight == .bold
      ? Font.system(textStyle).bold()
      : .system(textStyle)
  }

  func make(
    _ size: CGFloat,
    weight: Font.Weight,
    allowDynamicType _: Bool /* ignored for sysFont */
  ) -> Font {
    .system(
      size: size,
      weight: weight
    )
  }
}

private struct MontserratFontMaker: AppFontMaking {
  var distinct: Bool = false

  func make(
    _ textStyle: Font.TextStyle,
    weight: Font.Weight?,
    allowDynamicType: Bool
  ) -> Font {
    let weight = weight ?? fontWeight(for: textStyle)

    if allowDynamicType {
      let size = preferedUIFont(for: textStyle).pointSize
      return .custom(
        MontserratFont(weight, distinct: distinct).name,
        size: size,
        relativeTo: textStyle
      )
    }

    return .custom(
      MontserratFont(weight, distinct: distinct).name,
      fixedSize: fontSizeFixed(for: textStyle)
    )
  }

  func make(
    _ size: CGFloat,
    weight: Font.Weight,
    allowDynamicType: Bool
  ) -> Font {
    if allowDynamicType {
      return .custom(
        MontserratFont(weight, distinct: distinct).name,
        size: size
      )
    }

    return .custom(
      MontserratFont(weight, distinct: distinct).name,
      fixedSize: size
    )
  }
}

private enum MontserratFont: String, CaseIterable {
  case regular = "Montserrat-Regular"
  case medium = "Montserrat-Medium"
  case bold = "Montserrat-Bold"
  case semiBold = "Montserrat-SemiBold"
  case light = "Montserrat-Light"
  case italic = "Montserrat-Italic"

  // case thin = "Montserrat-Thin"
  // case extraLight = "Montserrat-ExtraLight"

  var name: String { rawValue }
}

private extension MontserratFont {
  init(_ weight: Font.Weight, distinct: Bool = false) {
    guard !distinct else {
      self = .italic
      return
    }

    self = {
      switch weight {
      case .regular: return .regular
      case .medium: return .medium
      case .bold: return .bold
      case .semibold: return .semiBold
      case .light: return .light
      // case .thin: return .thin
      case .ultraLight:
        //        Loggers.default.error("MontserratFontMaker .extraLight not yet added. Using .light")
        return .light
      case .heavy:
        //        Loggers.default.error("MontserratFontMaker .heavy not yet added. Using .bold")
        return .bold
      case .black:
        //        Loggers.default.error("MontserratFontMaker .black not yet added. Using .bold")
        return .bold
      default:
        //        Loggers.default.error("MontserratFontMaker unknown weight \(weight). Using .regular")
        return .regular
      }
    }()
  }
}

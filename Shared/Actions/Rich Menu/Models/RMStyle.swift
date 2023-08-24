import AppIntents
import SwiftUI


/// A Style for an Icon or it's background
enum RMStyle: String, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Style"
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .default: "Default",
            .red: "red",
            .orange: "orange",
            .yellow: "yellow",
            .green: "green",
            .mint: "mint",
            .teal: "teal",
            .cyan: "cyan",
            .blue: "blue",
            .purple: "purple",
            .pink: "pink",
            .brown: "brown",
            .white: "white",
            .gray: "gray",
            .black: "black",
            .clear: "clear"
        ]
    }

    case `default`
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case blue
    case purple
    case pink
    case brown
    case white
    case gray
    case black
    case clear

    /// Converts to color
    /// - Parameter isBackground: differentiator for default color
    /// - Returns: Color
    func color(isBackground: Bool = false) -> Color {
        switch self {
        case .default:
            return isBackground ? .white : .gray
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .mint:
            return .mint
        case .teal:
            return .teal
        case .cyan:
            return .cyan
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .brown:
            return .brown
        case .white:
            return .white
        case .gray:
            return .gray
        case .black:
            return .black
        case .clear:
            return .clear
        }
    }
}

import Foundation
import AppIntents
import SwiftUI

/// Shape for an Icon's Background
enum RMBackgroundShape: String, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Background Shape"
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .circle: DisplayRepresentation(title: "Circle"),
        .square: DisplayRepresentation(title: "Square"),
        .noBackground: DisplayRepresentation(title: "No Background")
    ]

    case circle
    case square
    case noBackground


    var shape: AnyShape? {
        switch self {
        case .circle:
            AnyShape(Circle())
        case .square:
            AnyShape(RoundedRectangle(cornerRadius: 10))
        case .noBackground:
            nil
        }
    }
}

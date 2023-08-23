import AppIntents
import Foundation

enum RMIconType: String, AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Icon Type"
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .sfSymbol: .init(
                title: "SF Symbol",
                image: .init(named: "circle.fill")
            ),
            .emoji: .init(
                title: "Emoji",
                image: .init(named: "face.smiling")
            )
        ]
    }

    case sfSymbol
    case emoji
}

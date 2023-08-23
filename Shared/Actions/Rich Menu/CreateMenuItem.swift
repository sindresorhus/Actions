//
//  CreateMenuItem.swift
//  Actions
//
//  Created by Noah Kamara on 22.08.23.
//

import Foundation
import AppIntents
import SwiftUI
import Contacts

struct CreateMenuItem: AppIntent {
    static var title: LocalizedStringResource {
        "Create Menu Item"
    }

    static let description = IntentDescription(
        """
        Create a Menu Item with a Title, Subtitle and Icon

        You can later use one or more of these Items in a "Choose From List" Action.

        Add an "Add To Variable" Action below this to populate a list and then use that variable in the "Choose From List" Action
        """,
        categoryName: "Rich Menu",
        searchKeywords: [
            "menu",
            "menu item",
            "choose from menu",
            "rich menu"
        ]
    )

    static var parameterSummary: some ParameterSummary {
        When(\.$menuTitle, .hasAnyValue) {
            Switch(\.$iconType) {
                // MARK: SFSymbol
                Case(RMIconType.sfSymbol) {
                    When(\.$backgroundShape, .notEqualTo, .noBackground) {
                        Summary("Create \(\.$systemName) with \(\.$menuTitle) and \(\.$subtitle)") {
                            \.$iconType
                            \.$foreground
                            \.$backgroundShape
                            \.$background
                            \.$data
                        }
                    } otherwise: {
                        Summary("Create \(\.$systemName) with \(\.$menuTitle) and \(\.$subtitle)") {
                            \.$iconType
                            \.$foreground
                            \.$backgroundShape
                            \.$background
                            \.$data
                        }
                    }
                }

                // MARK: Emoji
                Case(RMIconType.emoji) {
                    When(\.$backgroundShape, .notEqualTo, .noBackground) {
                        Summary("Create \(\.$emoji) with \(\.$menuTitle) and \(\.$subtitle)") {
                            \.$iconType
                            \.$backgroundShape
                            \.$background
                            \.$data
                        }
                    } otherwise: {
                        Summary("Create \(\.$emoji) with \(\.$menuTitle) and \(\.$subtitle)") {
                            \.$iconType
                            \.$foreground
                            \.$backgroundShape
                            \.$background
                            \.$data
                        }
                    }
                }

                DefaultCase {
                    Summary("Create Item with \(\.$menuTitle) and \(\.$subtitle)") {
                        \.$iconType
                        \.$backgroundShape
                        \.$background
                        \.$data
                    }
                }
            }
        } otherwise: {
            // MARK: No Title
            Summary("Create Menu Item with \(\.$menuTitle)")
        }
    }

    @Parameter(title: "Title")
    var menuTitle: String

    @Parameter(title: "Subtitle")
    var subtitle: String?

    @Parameter(
        title: "Icon",
        default: .sfSymbol
    )
    var iconType: RMIconType

    @Parameter(
        title: "Background",
        description: """
        A Background for your Icon

        Use this in combination with Background Shape to show a background behind your icon
        """,
        default: .default
    )
    var background: RMStyle

    // SF Symbol
    @Parameter(
        title: "SF Symbol Name",
        description: """
        The Name of a SF Symbol

        For available Symbols see Apple's Website (https://developer.apple.com/sf-symbols/) ])
        """,
        default: "plus"
    )
    var systemName: String

    @Parameter(
        title: "Foreground",
        description: "The Color for your SF Symbol",
        default: .default
    )
    var foreground: RMStyle

    // Emoji
    @Parameter(
        title: "Emoji",
        description: """
        Any Emoji 😀.

        Tap the Emoji button on your keyboard and select one emoji.
        """,
        default: "😀",
        inputOptions: .init(keyboardType: .default)
    )
    var emoji: String

    @Parameter(
        title: "Data"
    )
    var data: String?

    @Parameter(
        title: "Background Style",
        description: """
        The style of the icon's background.
        """,
        default: .circle
    )
    var backgroundShape: RMBackgroundShape

    func makeIcon() async -> Data? {
        switch iconType {
        case .sfSymbol:
            return await RMIconContainer(
                sfSymbol: systemName,
                foregroundColor: foreground.color(),
                backgroundColor: background.color(isBackground: true),
                backgroundShape: backgroundShape
            )
            .render()
        case .emoji:
            return await RMIconContainer(
                emoji: emoji,
                backgroundColor: background.color(isBackground: true),
                backgroundShape: backgroundShape
            )
            .render()
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<MenuItem>  {
        let icon = await makeIcon()

        let item = MenuItem(
            title: menuTitle,
            subtitle: subtitle,
            icon: icon
        )

        return .result(value: item)
    }
}

struct MenuItem: TransientAppEntity {
    init() {
        self.init(title: nil, subtitle: nil)
    }

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Menu Item"
    }

    var displayRepresentation: DisplayRepresentation {
        let title: LocalizedStringResource = "\(title ?? "")"
        let subtitle: LocalizedStringResource? = if let subtitle  { "\(subtitle)" } else { nil }
        let image: DisplayRepresentation.Image? = if let icon {
            if #available(iOS 17.0, macOS 14.0, *) {
                .init(data: icon.data, displayStyle: .default)
            } else {
                .init(data: icon.data)
            }
        } else {
            nil
        }

        return if let subtitle {
            DisplayRepresentation(
                title: title,
                subtitle: subtitle,
                image: image
            )
        } else {
            DisplayRepresentation(
                title: title,
                subtitle: nil,
                image: image
            )
        }
    }

    @Property(title: "Title")
    var title: String?

    @Property(title: "Subtitle")
    var subtitle: String?

    @Property(title: "Icon")
    var icon: IntentFile?

    init(
        title: String? = nil,
        subtitle: String? = nil,
        icon: Data? = nil
    ) {
        if let icon {
            self.icon = .init(data: icon, filename: "icon.png", type: .image)
        } else {
            self.icon = nil
        }
        self.title = title
        self.subtitle = subtitle
    }
}

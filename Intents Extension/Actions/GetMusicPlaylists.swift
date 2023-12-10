import AppIntents
import MediaPlayer

@available(macOS, unavailable)
struct GetMusicPlaylistsIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Music Playlists (iOS-only)"

	static let description = IntentDescription(
		"Returns the names of the playlists in your Music library.",
		categoryName: "Music",
		resultValueName: "Music Playlists"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		let playlists = MPMediaQuery.playlists().collections as? [MPMediaPlaylist]
		let playlistNames = playlists?.compactMap(\.name) ?? []

		// This is intentionally after so we don't have to explicitly request access before checking.
		guard MPMediaLibrary.authorizationStatus() == .authorized else {
			throw "No access to the Music library. You can grant access in “Settings › Actions”.".toError
		}

		return .result(value: playlistNames)
	}
}

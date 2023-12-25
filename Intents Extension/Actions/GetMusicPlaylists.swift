import AppIntents
import MediaPlayer

// TODO: Deprecate this in favor of `Find Music Playlist` at some point.

@available(macOS, unavailable)
struct GetMusicPlaylistsIntent: AppIntent {
	static let title: LocalizedStringResource = "Get Music Playlists"

	static let description = IntentDescription(
		"""
		Returns the names of the playlists in your Music library.

		See the “Find Music Playlist” action for more advanced functionality.
		""",
		categoryName: "Music",
		resultValueName: "Music Playlists"
	)

	func perform() async throws -> some IntentResult & ReturnsValue<[String]> {
		let playlistNames = try await MPMediaLibrary.getPlaylists().compactMap(\.name)
		return .result(value: playlistNames)
	}
}

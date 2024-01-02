import AppIntents
import MediaPlayer

@available(macOS, unavailable)
struct MusicPlaylist_AppEntity: AppEntity {
	static let typeDisplayRepresentation: TypeDisplayRepresentation = "Music Playlist"

	static let defaultQuery = Query()

	@Property(title: "Name")
	var name: String

	@Property(title: "Identifier")
	var id: String

	@Property(title: "Date Created")
	var dateCreated: Date

	@Property(title: "Date Modified")
	var dateModified: Date

	@Property(title: "Date Last Played")
	var dateLastPlayed: Date

	@Property(title: "Song Count")
	var songCount: Int

	init(_ playlist: MPMediaPlaylist) {
		self.name = playlist.name ?? ""
		self.id = "\(playlist.persistentID)"
		self.dateCreated = playlist.dateCreated
		self.dateModified = playlist.dateModified
		self.dateLastPlayed = playlist.dateLastPlayed ?? playlist.dateCreated
		self.songCount = playlist.count
	}

	var displayRepresentation: DisplayRepresentation {
		.init(title: "\(name)")
	}
}

@available(macOS, unavailable)
extension MusicPlaylist_AppEntity {
	struct Query: EnumerableEntityQuery {
		static let findIntentDescription = IntentDescription(
			"""
			Returns the playlists in your Music library.

			iOS-only

			Use the built-in “Show Result” action to inspect the individual properties.
			""",
			categoryName: "Music",
			searchKeywords: [
				"playlist",
				"song"
			],
			resultValueName: "Music Playlists"
		)

		func allEntities() async throws -> [MusicPlaylist_AppEntity] {
			try await MPMediaLibrary.getPlaylists()
				.map(MusicPlaylist_AppEntity.init)
		}

		func entities(for identifiers: [MusicPlaylist_AppEntity.ID]) async throws -> [MusicPlaylist_AppEntity] {
			try await allEntities().filter { identifiers.contains($0.id) }
		}

		func suggestedEntities() async throws -> [MusicPlaylist_AppEntity] {
			try await allEntities()
		}
	}
}

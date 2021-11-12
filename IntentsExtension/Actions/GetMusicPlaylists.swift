import Foundation
import MediaPlayer

@MainActor
final class GetMusicPlaylistsIntentHandler: NSObject, GetMusicPlaylistsIntentHandling {
	func handle(intent: GetMusicPlaylistsIntent) async -> GetMusicPlaylistsIntentResponse {
		let response = GetMusicPlaylistsIntentResponse(code: .success, userActivity: nil)

		if let playlists = MPMediaQuery.playlists().collections as? [MPMediaPlaylist] {
			response.result = playlists.compactMap(\.name)
		}

		// This is intentionally after so we don't have to explicitly request access before checking.
		guard MPMediaLibrary.authorizationStatus() == .authorized else {
			return .failure(failure: "No access to the Music library. You can grant access in “Settings › Actions”.")
		}

		return response
	}
}

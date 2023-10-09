import AppIntents
import AVFoundation

struct CombineVideosIntent: AppIntent {
	static let title: LocalizedStringResource = "Combine Videos"

	static let description = IntentDescription(
"""
Combine videos into a single video.

IMPORTANT: The videos must have the same size and orientation.

This can be useful for combining Live Photos.

It uses passthrough whenever possible to prevent unnecessary transcoding, preserving original video quality.

NOTE: Shortcut actions only get 30 seconds to run, so if the videos are very long, it may not work.
""",
		categoryName: "Video",
		searchKeywords: [
			"merge",
			"edit",
			"live",
			"photo",
			"clip",
			"movie",
			"mp4",
			"mov",
			"quicktime"
		]
	)

	@Parameter(
		title: "Videos",
		description: "Accepts MP4 and MOV videos.",
		supportedTypeIdentifiers: [
			"public.mpeg-4",
			"com.apple.quicktime-movie"
		]
	)
	var videos: [IntentFile]

	static var parameterSummary: some ParameterSummary {
		Summary("Combine videos \(\.$videos) (MUST HAVE SAME SIZE & ORIENTATION)")
	}

	func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
		let videoAssets = try videos.map {
			AVURLAsset(url: try $0.writeToUniqueTemporaryFile())
		}

		defer {
			for videoAsset in videoAssets {
				try? FileManager.default.removeItem(at: videoAsset.url)
			}
		}

		let result = try await combineVideos(videoAssets)
			.toIntentFile
			.removingOnCompletion()

		return .result(value: result)
	}
}

private func combineVideos(_ videos: [AVAsset]) async throws -> URL {
	guard videos.count >= 2 else {
		throw "Expected two or more videos, got \(videos.count).".toError
	}

	let composition = AVMutableComposition()

	guard
		let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
		let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
	else {
		throw "Failed to create video composition.".toError
	}

	var insertTime = CMTime.zero

	for (index, video) in videos.indexed() {
		guard let videoTrack = try await video.loadTracks(withMediaType: .video).first else {
			throw "Missing video track from video.".toError
		}

		let duration = try await video.load(.duration)

		try videoCompositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: videoTrack, at: insertTime)

		if let audioTrack = try await video.loadTracks(withMediaType: .audio).first {
			try audioCompositionTrack.insertTimeRange(CMTimeRange(start: .zero, duration: duration), of: audioTrack, at: insertTime)
		}

		// swiftlint:disable:next shorthand_operator
		insertTime = insertTime + duration

		if index == 0 {
			videoCompositionTrack.preferredTransform = try await videoTrack.load(.preferredTransform)
		}
	}

	guard
		let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough)
	else {
		throw "Failed to create export session.".toError
	}

	let url = try URL.uniqueTemporaryDirectory().appending(path: "Combined Video.mp4", directoryHint: .notDirectory)

	exporter.outputURL = url
	exporter.outputFileType = .mp4
	exporter.shouldOptimizeForNetworkUse = true

	await exporter.export()

	if let error = exporter.error {
		throw error
	}

	return url
}

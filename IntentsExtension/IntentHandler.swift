import Intents

@MainActor
final class IntentHandler: INExtension {
	override init() {
		super.init()
		setUpSentry()
	}

	override func handler(for intent: INIntent) -> Any? {
		switch intent {
		case is TransformTextIntent:
			return TransformTextIntentHandler()
		case is GenerateUUIDIntent:
			return GenerateUUIDIntentHandler()
		case is RandomEmojiIntent:
			return RandomEmojiIntentHandler()
		case is RandomBooleanIntent:
			return RandomBooleanIntentHandler()
		case is RemoveEmojiIntent:
			return RemoveEmojiIntentHandler()
		case is TrimWhitespaceIntent:
			return TrimWhitespaceIntentHandler()
		case is RandomDateTimeIntent:
			return RandomDateTimeIntentHandler()
		case is RandomFloatingPointNumberIntent:
			return RandomFloatingPointNumberIntentHandler()
		case is SortListIntent:
			return SortListIntentHandler()
		case is ShuffleListIntent:
			return ShuffleListIntentHandler()
		case is RemoveDuplicatesFromListIntent:
			return RemoveDuplicatesFromListIntentHandler()
		case is ReverseListIntent:
			return ReverseListIntentHandler()
		case is ClampNumberIntent:
			return ClampNumberIntentHandler()
		case is RemoveEmptyLinesIntent:
			return RemoveEmptyLinesIntentHandler()
		case is TransformTextWithJavaScriptIntent:
			return TransformTextWithJavaScriptIntentHandler()
		case is RandomColorIntent:
			return RandomColorIntentHandler()
		#if canImport(AppKit)
		case is SampleColorIntent:
			return SampleColorIntentHandler()
		#endif
		case is GetUniformTypeIdentifierIntent:
			return GetUniformTypeIdentifierIntentHandler()
		case is FormatDateDifferenceIntent:
			return FormatDateDifferenceIntentHandler()
		case is GetFilePathIntent:
			return GetFilePathIntentHandler()
		case is DateToUnixTimeIntent:
			return DateToUnixTimeIntentHandler()
		case is UnixTimeToDateIntent:
			return UnixTimeToDateIntentHandler()
		case is CreateURLIntent:
			return CreateURLIntentHandler()
		case is RemoveDuplicateLinesIntent:
			return RemoveDuplicateLinesIntentHandler()
		case is AddToListIntent:
			return AddToListIntentHandler()
		case is RandomTextIntent:
			return RandomTextIntentHandler()
		case is RemoveFromListIntent:
			return RemoveFromListIntentHandler()
		case is ApplyCaptureDateIntent:
			return ApplyCaptureDateIntentHandler()
		case is SetFileCreationModificationDateIntent:
			return SetFileCreationModificationDateIntentHandler()
		case is CombineListsIntent:
			return CombineListsIntentHandler()
		#if canImport(UIKit)
		case is GetMusicPlaylistsIntent:
			return GetMusicPlaylistsIntentHandler()
		#endif
		case is FilterListIntent:
			return FilterListIntentHandler()
		case is TruncateListIntent:
			return TruncateListIntentHandler()
		case is GetEmojisIntent:
			return GetEmojisIntentHandler()
		case is SendFeedbackIntent:
			return SendFeedbackIntentHandler()
		#if canImport(UIKit)
		case is IsAudioPlayingIntent:
			return IsAudioPlayingIntentHandler()
		#endif
		case is IsBluetoothOnIntent:
			return IsBluetoothOnIntentHandler()
		case is IsDarkModeIntent:
			return IsDarkModeIntentHandler()
		case is WriteTextIntent:
			return WriteTextIntentHandler()
		case is GetUserDetailsIntent:
			return GetUserDetailsIntentHandler()
		#if canImport(UIKit)
		case is IsConnectedToVPNIntent:
			return IsConnectedToVPNIntentHandler()
		#endif
		case is EditURLIntent:
			return EditURLIntentHandler()
		case is GetTitleOfURLIntent:
			return GetTitleOfURLIntentHandler()
		case is GetBatteryStateIntent:
			return GetBatteryStateIntentHandler()
		case is IsLowPowerModeIntent:
			return IsLowPowerModeIntentHandler()
		case is RemoveNonPrintableCharactersIntent:
			return RemoveNonPrintableCharactersIntentHandler()
		case is FormatCurrencyIntent:
			return FormatCurrencyIntentHandler()
		case is HideShortcutsAppIntent:
			return HideShortcutsAppIntentHandler()
		default:
			assertionFailure("No handler for this intent")
			return nil
		}
	}
}

import AppIntents
import SoulverCore

struct CalculateWithSoulver: AppIntent {
	static let title: LocalizedStringResource = "Calculate with Soulver"

	static let description = IntentDescription(
"""
Lets you calculate day-to-day math expressions using natural language, provided by Soulver.


Examples:

$10 for lunch + 15% tip
→ $11.50

65 kg in pounds
→ 154.32 lb

$2 in euro
→ €2,02

12% of 478
→ 57.36

40 as % of 90
→ 44.44%

$150 is 25% on what
→ $120.00

$25/hour * 14 hours of work
→ $350.00

January 30 2020 + 3 months 2 weeks 5 days
→ May 19, 2020

9:35am in New York to Japan
→ 10:35 pm

days until April
→ 37 days

days left in Feb
→ 5 days

days remaining in 2023
→ 311 days

$25k over 10 years at 7.5%
→ $51,525.79 (compound interest)


The expression can be written in English, German, Russian, or Simplified Chinese.

If you like this action, you may also like the Soulver macOS app.
""",
		categoryName: "Math"
	)

	@Parameter(
		title: "Expression",
		inputOptions: .init(
			capitalizationType: .none,
			autocorrect: false,
			smartQuotes: false,
			smartDashes: false
		)
	)
	var expression: String

	@Parameter(title: "Decimal Places", default: 2, inclusiveRange: (0, 999))
	var decimalPlaces: Int

	@Parameter(title: "Show Thousands Separator", default: true)
	var showThousandsSeparator: Bool

	@Parameter(
		title: "Abbreviate Large Numbers",
		description: "Show numbers from a million and up as “1.35M” instead of “1350000”.",
		default: true
	)
	var abbreviateLargeNumbers: Bool

	@Parameter(
		title: "Use Live Currency Rates",
		description: "This will make the action run slower. It will fall back to the built-in rates if the live rates cannot be fetched.",
		default: false
	)
	var useLiveCurrencyRates: Bool

	static var parameterSummary: some ParameterSummary {
		Summary("Calculate \(\.$expression)") {
			\.$decimalPlaces
			\.$showThousandsSeparator
			\.$abbreviateLargeNumbers
			\.$useLiveCurrencyRates
		}
	}

	func perform() async throws -> some IntentResult & ReturnsValue<String> {
		let result = await calculate(liveCurrencyRates: useLiveCurrencyRates)
		return .result(value: result)
	}

	private func calculate(liveCurrencyRates: Bool) async -> String {
		var customization = EngineCustomization.standard
		customization.featureFlags.allowMisplacedThousandsSeparators = false

		let ecbCurrencyRateProvider = ECBCurrencyRateProvider()

		if liveCurrencyRates {
			customization.currencyRateProvider = ecbCurrencyRateProvider
		}

		let calculator = Calculator(customization: customization)

		var formattingPreferences = FormattingPreferences()
		formattingPreferences.dp = decimalPlaces
		formattingPreferences.thousandsSeparatorDisabled = !showThousandsSeparator
		formattingPreferences.notationPreferences = abbreviateLargeNumbers ? .init(notationStyle: .auto, upperNotationThreshold: .million) : .off
		calculator.formattingPreferences = formattingPreferences

		if liveCurrencyRates {
			// We gracefully handle rate fetching failure and fall back to local rates.
			guard await ecbCurrencyRateProvider.updateRates() else {
				return await calculate(liveCurrencyRates: false)
			}
		}

		return calculator.calculate(expression).stringValue
	}
}

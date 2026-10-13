# Test Plan — ShapelyParentalGate

Unit tests live in `Tests/ShapelyParentalGateTests` and use **Swift Testing**. Run them with:

```sh
xcodebuild test -scheme ShapelyParentalGate -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
```

## LocalizedStringTests — `Localizer` / `String.localized`

`@Suite(.serialized) @MainActor struct`. `Localizer.overrideDictionary` is a process-wide static, and Swift Testing runs tests in parallel
by default. The suite runs serially, resets the override to `nil` in `init`, and each test that installs an override clears it again with
`defer`. It is `@MainActor` because the view model suites also read `Localizer` (every view model init localizes its strings). Putting all
`Localizer` users on the main actor means their synchronous test bodies can never overlap.

| # | Test | Verifies |
|---|---|---|
| 1 | Default strings load from the package plist | `"Primary/Title"` resolves to `"Parental Gate"` from `en.lproj/DefaultLocalizedStrings.plist` |
| 2 | Override plist takes precedence over defaults | With `OverrideLocalizedStrings.plist` installed, `"Primary/Title"` resolves to `"Override Title"` |
| 3 | Keys missing from the override fall back to defaults | With the override installed, `"Primary/Countdown"` (absent from the override) still resolves to `"Time Left:"` |
| 4 | Unknown key returns MISSING STRING | `"Primary/ShouldNotFind"` resolves to the `"MISSING STRING"` sentinel |

Fixture: `Resources/OverrideLocalizedStrings.plist` overrides only `Primary/Title`. It uses the real `Primary` category so test 2 proves
precedence over an existing default, not just lookup of an extra key.

Tests 1 and 3 assume an English simulator, since the default plist is chosen by locale.

## StaticConfigurationTests — `ShapelyParentalGateStaticConfiguration`

`struct` suite with no shared state.

| # | Test | Verifies |
|---|---|---|
| 5 | All values default to nil except supportsTimeOut | Default init leaves every value `nil` except `supportsTimeOut == true` |
| 6 | Explicit values are stored | Every initializer argument is stored unchanged |

## CountdownFormattingTests — `ShapelyParentalGateViewModel.formattedCountdown(_:locale:)`

`struct` suite with no shared state. The formatter is a `nonisolated static` pure function, so the tests don't build a view model, don't
touch `Localizer`, and can't race the localization suite.

| # | Test | Verifies |
|---|---|---|
| 7 | Countdown formats as zero-padded minutes and seconds (parameterized) | In `en_US`: 0 → `00:00`, 9 → `00:09`, 10 → `00:10`, 59 → `00:59`, 60 → `01:00`, 90 → `01:30`, 600 → `10:00`, 3661 → `61:01`. These exactly match the old `String(format: "%02d:%02d")` output |
| 8 | Countdown follows the locale's conventions (parameterized) | 90 s → `01.30` in `fi_FI` (period separator) and `٠١:٣٠` in `ar_EG` (Arabic-Indic digits) |

## ViewModelTimerTests — `ShapelyParentalGateViewModel.tick()`

`@MainActor struct` (the view model is `@MainActor` and its init reads `Localizer`). Expected countdown text is built with
`formattedCountdown(_:)` so the tests don't depend on the simulator's locale.

| # | Test | Verifies |
|---|---|---|
| 9 | Countdown defaults to 10 seconds with time-out enabled | Default configuration → `supportsTimeOut`, `countdown == 10`, matching text |
| 10 | Countdown starts at the configured time | `maximumTimeAllowed: 13` → `countdown == 13`, matching text |
| 11 | Each tick decrements the countdown and updates its text | One tick from 13 → 12, text updated, no alert |
| 12 | Reaching zero raises the time-expired alert | Two ticks from 2 → 0, `showAlert`, alert strings are the `TimeExpired/*` ones |
| 13 | Ticks after zero change nothing | Extra ticks at 0 leave `countdown == 0` |
| 14 | Ticks do nothing when time-out is disabled | `supportsTimeOut: false` → tick leaves countdown and text unchanged, no alert |

## ViewModelAttemptTests — `ShapelyParentalGateViewModel.shapelyScene(_:dropped:)`

`@MainActor struct`. The target shape is injected through `init(configuration:successShape:)` (an internal, test-only seam; the view
still gets a random shape), so the tests are deterministic.

| # | Test | Verifies |
|---|---|---|
| 15 | Dropping the target shape succeeds (parameterized over all 4 shapes) | Returns `true`, sets `succeeded`, no alert |
| 16 | A wrong drop is a miss but not yet a failure | With the default 2-miss limit, one wrong drop returns `false`, no success, no alert |
| 17 | Two misses fail by default | Second wrong drop raises the alert with the `TooManyAttempts/*` strings |
| 18 | The alert appears exactly at the configured miss limit (parameterized: 1, 3, 5) | No alert after `limit − 1` misses, alert on miss number `limit` |
| 19 | A drop with no recognizable shape is ignored | `dropped: nil` returns `false` and doesn't count toward the limit |
| 20 | The target shape still succeeds after a miss | One wrong drop, then the right one → `succeeded`, no alert |

## Candidates for later

- Every key in the README's "String keys" table resolves (not `MISSING STRING`) in both `en` and `es`, as a parameterized test. That would
  catch renames like `ViewController` → `Primary`.
- `ShapelyParentalGateViewModel`: `descriptionText` matches the target shape (parameterized over all four shapes).
- Configuration default for `numberOfEachShape` (2) reaches the scene via `makeScene(size:)`.

# Test Plan — ShapelyParentalGate

Unit tests live in `Tests/ShapelyParentalGateTests` and use **Swift Testing**. Run them with:

```sh
xcodebuild test -scheme ShapelyParentalGate -destination 'platform=iOS Simulator,name=iPhone 18 Pro'
```

## LocalizedStringTests — `Localizer` / `String.localized`

`@Suite(.serialized)`, `final class`. `Localizer.overrideDictionary` is a process-wide static, and Swift Testing runs tests in parallel by
default. The suite runs serially and resets the override to `nil` in `init` and `deinit`, so no test sees another's override.

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

## Candidates for later

- Every key in the README's "String keys" table resolves (not `MISSING STRING`) in both `en` and `es`, as a parameterized test. That would
  catch renames like `ViewController` → `Primary`.
- `ShapelyParentalGateViewModel`: `tick()` counts down, formats `mm:ss`, and raises the TimeExpired alert at zero.
- `ShapelyParentalGateViewModel`: a wrong drop increments failures, and reaching `maximumFailedAttempts` raises the TooManyAttempts alert. A
  correct drop sets `succeeded`.
- Configuration defaults applied by the view model (2 attempts, 10 s, 2 of each shape, timeout on).

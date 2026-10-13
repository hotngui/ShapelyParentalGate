//
// Created by Joey Jarosz on 10/13/26.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import Foundation
import Testing
@testable import ShapelyParentalGate

/// The countdown label used to be built with `String(format: "%02d:%02d")`. These tests pin that output for English and verify the
/// replacement format style also adapts to other locales.
///
struct CountdownFormattingTests {
    @Test("Countdown formats as zero-padded minutes and seconds", arguments: [
        (0, "00:00"), (9, "00:09"), (10, "00:10"), (59, "00:59"),
        (60, "01:00"), (90, "01:30"), (600, "10:00"), (3661, "61:01")
    ])
    func zeroPaddedMinutesAndSeconds(seconds: Int, expected: String) {
        let formatted = ShapelyParentalGateViewModel.formattedCountdown(seconds, locale: Locale(identifier: "en_US"))

        #expect(formatted == expected)
    }

    @Test("Countdown follows the locale's conventions", arguments: [
        ("fi_FI", "01.30"), ("ar_EG", "٠١:٣٠")
    ])
    func localeConventions(localeIdentifier: String, expected: String) {
        let formatted = ShapelyParentalGateViewModel.formattedCountdown(90, locale: Locale(identifier: localeIdentifier))

        #expect(formatted == expected)
    }
}

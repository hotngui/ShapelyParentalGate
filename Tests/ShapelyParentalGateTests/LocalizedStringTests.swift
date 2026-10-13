//
// Created by Joey Jarosz on 9/13/20.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import Foundation
import Testing
@testable import ShapelyParentalGate

/// `Localizer.overrideDictionary` is a process-wide static, so these tests run serially and leave it `nil` when they finish. The
/// suite is `@MainActor` because the view model suites read `Localizer` too; keeping every `Localizer` user on the main actor means
/// their synchronous test bodies can never overlap.
///
@Suite(.serialized)
@MainActor
struct LocalizedStringTests {
    init() {
        Localizer.overrideDictionary = nil
    }

    @Test("Default strings load from the package plist") func defaultStrings() {
        #expect("Primary/Title".localized == "Parental Gate", "Unable to read from the default localized strings Plist file.")
    }

    @Test("Override plist takes precedence over defaults") func overrideTakesPrecedence() throws {
        Localizer.overrideDictionary = try loadOverrideDictionary()
        defer { Localizer.overrideDictionary = nil }

        #expect("Primary/Title".localized == "Override Title", "Unable to read from the override Plist file.")
    }

    @Test("Keys missing from the override fall back to defaults") func missingOverrideKeysFallBack() throws {
        Localizer.overrideDictionary = try loadOverrideDictionary()
        defer { Localizer.overrideDictionary = nil }

        #expect("Primary/Countdown".localized == "Time Left:")
    }

    @Test("Unknown key returns MISSING STRING") func unknownKey() {
        #expect("Primary/ShouldNotFind".localized == "MISSING STRING")
    }

    private func loadOverrideDictionary() throws -> NSDictionary {
        let filePath = try #require(Bundle.module.path(forResource: "OverrideLocalizedStrings", ofType: "plist"))
        return try #require(NSDictionary(contentsOfFile: filePath))
    }
}

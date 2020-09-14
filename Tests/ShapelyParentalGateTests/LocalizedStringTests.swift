//
// Created by Joey Jarosz on 9/13/20.
// Copyright © 2020 hot-n-GUI, LLC. All rights reserved.
//

import XCTest
@testable import ShapelyParentalGate

final class LocalizedStringTests: XCTestCase {
    func testDefaults() {
        let title = "ViewController/Title".localized
        XCTAssertEqual(title, "Parental Gate", "Unable to read from the default localized strings Plist file.")
    }

    func testOverrides() {
        guard let filePath = Bundle.module.path(forResource: "OverrideLocalizedStrings", ofType: "plist") else {
            XCTAssert(false)
            return
        }

        guard let dictionary = NSDictionary(contentsOfFile: filePath) else {
            XCTAssert(false)
            return
        }

        Localizer.overrideDictionary = dictionary

        let title = "ViewController/Title".localized
        XCTAssertEqual(title, "Override Title", "Unable to read from the override Plist file.")
    }

    func testMissingString() {
        let title = "ViewController/ShouldNotFind".localized
        XCTAssertEqual(title, "MISSING STRING", "Unable to read from the default localized strings Plist file.")
    }
}

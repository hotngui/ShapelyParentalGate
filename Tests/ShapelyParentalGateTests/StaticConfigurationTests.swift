//  
// Created by Joey Jarosz on 9/13/20.
// Copyright © 2020 hot-n-GUI, LLC. All rights reserved.
//

import XCTest
@testable import ShapelyParentalGate

/// True, the _ShapelyParentalGateStaticConfiguration_ struct has nothing but getters, but since I have a habit of forgetting to set the correct default
/// values I figure might as well write a couple of tests.
///
final class StaticConfiguration: XCTestCase {
    func testAllDefaultValue() {
        let configuration = ShapelyParentalGateStaticConfiguration()

        XCTAssertNil(configuration.localizedStringsFilePath)
        XCTAssertNil(configuration.maximumFailedAttempts)
        XCTAssertEqual(configuration.supportsTimeOut, true)
        XCTAssertNil(configuration.maximumTimeAllowed)
        XCTAssertNil(configuration.numberOfEachShape)
    }

    func testAllValuesExplicit() {
        let configuration = ShapelyParentalGateStaticConfiguration(localizedStringsFilePath: "/file/path",
                                                                   maximumFailedAttempts: 666,
                                                                   supportsTimeOut: false,
                                                                   maximumTimeAllowed: 111,
                                                                   numberOfEachShape: 6)

        XCTAssertEqual(configuration.localizedStringsFilePath, "/file/path")
        XCTAssertEqual(configuration.maximumFailedAttempts, 666)
        XCTAssertEqual(configuration.supportsTimeOut, false)
        XCTAssertEqual(configuration.maximumTimeAllowed, 111)
        XCTAssertEqual(configuration.numberOfEachShape, 6)
    }
}


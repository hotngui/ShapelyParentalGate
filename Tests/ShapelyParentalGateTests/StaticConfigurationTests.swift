//
// Created by Joey Jarosz on 9/13/20.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import Testing
@testable import ShapelyParentalGate

/// True, the _ShapelyParentalGateStaticConfiguration_ struct has nothing but getters, but since I have a habit of forgetting
/// to set the correct default values I figure might as well write a couple of tests.
///
struct StaticConfigurationTests {
    @Test("All values default to nil except supportsTimeOut") func allDefaultValues() {
        let configuration = ShapelyParentalGateStaticConfiguration()

        #expect(configuration.localizedStringsFilePath == nil)
        #expect(configuration.maximumFailedAttempts == nil)
        #expect(configuration.supportsTimeOut == true)
        #expect(configuration.maximumTimeAllowed == nil)
        #expect(configuration.numberOfEachShape == nil)
    }

    @Test("Explicit values are stored") func allValuesExplicit() {
        let configuration = ShapelyParentalGateStaticConfiguration(localizedStringsFilePath: "/file/path",
                                                                   maximumFailedAttempts: 666,
                                                                   supportsTimeOut: false,
                                                                   maximumTimeAllowed: 111,
                                                                   numberOfEachShape: 6)

        #expect(configuration.localizedStringsFilePath == "/file/path")
        #expect(configuration.maximumFailedAttempts == 666)
        #expect(configuration.supportsTimeOut == false)
        #expect(configuration.maximumTimeAllowed == 111)
        #expect(configuration.numberOfEachShape == 6)
    }
}

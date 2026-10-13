//
// Created by Joey Jarosz on 10/13/26.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import CoreGraphics
import Testing
@testable import ShapelyParentalGate

/// Drop handling in `ShapelyParentalGateViewModel.shapelyScene(_:dropped:)`. The target shape is injected so the tests are
/// deterministic; in the app it is chosen at random.
///
@MainActor
struct ViewModelAttemptTests {
    private let scene = ShapelyScene(size: CGSize(width: 400, height: 800))

    @Test("Dropping the target shape succeeds", arguments: ShapelyScene.Shape.allCases)
    func targetShapeSucceeds(shape: ShapelyScene.Shape) {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(), successShape: shape)

        #expect(viewModel.shapelyScene(scene, dropped: shape))
        #expect(viewModel.succeeded)
        #expect(!viewModel.showAlert)
    }

    @Test("A wrong drop is a miss but not yet a failure") func singleMiss() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(), successShape: .circle)

        #expect(!viewModel.shapelyScene(scene, dropped: .square))
        #expect(!viewModel.succeeded)
        #expect(!viewModel.showAlert)
    }

    @Test("Two misses fail by default") func twoMissesFailByDefault() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(), successShape: .circle)

        _ = viewModel.shapelyScene(scene, dropped: .square)
        _ = viewModel.shapelyScene(scene, dropped: .triangle)

        #expect(!viewModel.succeeded)
        #expect(viewModel.showAlert)
        #expect(viewModel.alertTitle == "TooManyAttempts/Title".localized)
        #expect(viewModel.alertMessage == "TooManyAttempts/Description".localized)
        #expect(viewModel.alertButtonTitle == "TooManyAttempts/OK".localized)
    }

    @Test("The alert appears exactly at the configured miss limit", arguments: [1, 3, 5])
    func alertAtConfiguredLimit(limit: Int) {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(maximumFailedAttempts: limit), successShape: .circle)

        for _ in 1..<limit {
            _ = viewModel.shapelyScene(scene, dropped: .pentagon)
        }
        #expect(!viewModel.showAlert)

        _ = viewModel.shapelyScene(scene, dropped: .pentagon)

        #expect(viewModel.showAlert)
    }

    @Test("A drop with no recognizable shape is ignored") func unrecognizedDropIgnored() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(maximumFailedAttempts: 1), successShape: .circle)

        #expect(!viewModel.shapelyScene(scene, dropped: nil))
        #expect(!viewModel.shapelyScene(scene, dropped: nil))

        #expect(!viewModel.succeeded)
        #expect(!viewModel.showAlert)
    }

    @Test("The target shape still succeeds after a miss") func successAfterMiss() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(), successShape: .triangle)

        #expect(!viewModel.shapelyScene(scene, dropped: .square))
        #expect(viewModel.shapelyScene(scene, dropped: .triangle))

        #expect(viewModel.succeeded)
        #expect(!viewModel.showAlert)
    }
}

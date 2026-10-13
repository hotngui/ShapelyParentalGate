//
// Created by Joey Jarosz on 10/13/26.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import Testing
@testable import ShapelyParentalGate

/// Countdown behavior of `ShapelyParentalGateViewModel.tick()`. Expected text comes from `formattedCountdown(_:)` so the tests
/// don't depend on the simulator's locale; the format itself is covered by `CountdownFormattingTests`.
///
@MainActor
struct ViewModelTimerTests {
    @Test("Countdown defaults to 10 seconds with time-out enabled") func defaultCountdown() {
        let viewModel = ShapelyParentalGateViewModel(configuration: ShapelyParentalGateStaticConfiguration())

        #expect(viewModel.supportsTimeOut)
        #expect(viewModel.countdown == 10)
        #expect(viewModel.countdownValueText == ShapelyParentalGateViewModel.formattedCountdown(10))
    }

    @Test("Countdown starts at the configured time") func configuredCountdown() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(maximumTimeAllowed: 13))

        #expect(viewModel.countdown == 13)
        #expect(viewModel.countdownValueText == ShapelyParentalGateViewModel.formattedCountdown(13))
    }

    @Test("Each tick decrements the countdown and updates its text") func tickDecrements() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(maximumTimeAllowed: 13))

        viewModel.tick()

        #expect(viewModel.countdown == 12)
        #expect(viewModel.countdownValueText == ShapelyParentalGateViewModel.formattedCountdown(12))
        #expect(!viewModel.showAlert)
    }

    @Test("Reaching zero raises the time-expired alert") func expiryRaisesAlert() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(maximumTimeAllowed: 2))

        viewModel.tick()
        #expect(!viewModel.showAlert)

        viewModel.tick()

        #expect(viewModel.countdown == 0)
        #expect(viewModel.countdownValueText == ShapelyParentalGateViewModel.formattedCountdown(0))
        #expect(viewModel.showAlert)
        #expect(viewModel.alertTitle == "TimeExpired/Title".localized)
        #expect(viewModel.alertMessage == "TimeExpired/Description".localized)
        #expect(viewModel.alertButtonTitle == "TimeExpired/OK".localized)
    }

    @Test("Ticks after zero change nothing") func ticksAfterZero() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(maximumTimeAllowed: 1))

        viewModel.tick()
        viewModel.tick()
        viewModel.tick()

        #expect(viewModel.countdown == 0)
        #expect(viewModel.countdownValueText == ShapelyParentalGateViewModel.formattedCountdown(0))
    }

    @Test("Ticks do nothing when time-out is disabled") func ticksIgnoredWithoutTimeOut() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init(supportsTimeOut: false, maximumTimeAllowed: 5))

        viewModel.tick()

        #expect(!viewModel.supportsTimeOut)
        #expect(viewModel.countdown == 5)
        #expect(viewModel.countdownValueText == ShapelyParentalGateViewModel.formattedCountdown(5))
        #expect(!viewModel.showAlert)
    }
}

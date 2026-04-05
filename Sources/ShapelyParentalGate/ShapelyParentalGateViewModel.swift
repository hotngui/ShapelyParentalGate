//
// Created by Joey Jarosz on 9/7/20.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import SwiftUI
import SpriteKit

/// The view model that manages all parental gate state and logic. It handles shape selection, countdown timing,
/// attempt tracking, and acts as the delegate for the SpriteKit scene.
///
@Observable
@MainActor
final class ShapelyParentalGateViewModel {

    // MARK: - Observable State

    var countdownValueText: String
    var showAlert = false
    var succeeded = false

    // MARK: - Alert State

    private(set) var alertTitle = ""
    private(set) var alertMessage = ""
    private(set) var alertButtonTitle = ""

    // MARK: - Configuration-Derived Properties

    let titleText: String
    let descriptionText: String
    let countdownLabelText: String
    let supportsTimeOut: Bool

    // MARK: - Private State

    private let maximumFailedAttempts: Int
    private let numberOfEachShape: Int

    private(set) var countdown: Int
    private var failedAttempts = 0
    private let successShape: ShapelyScene.Shape

    private var scene: ShapelyScene?

    // MARK: - Init

    init(configuration: ShapelyParentalGateStaticConfiguration) {
        let maxFailed = configuration.maximumFailedAttempts ?? 2
        let maxTime = configuration.maximumTimeAllowed ?? 10
        let shapeCount = configuration.numberOfEachShape ?? 2
        let timeOutEnabled = configuration.supportsTimeOut ?? true

        self.maximumFailedAttempts = maxFailed
        self.countdown = maxTime
        self.numberOfEachShape = shapeCount
        self.supportsTimeOut = timeOutEnabled

        // Apply localization overrides if provided
        if let filePath = configuration.localizedStringsFilePath,
           let dictionary = NSDictionary(contentsOfFile: filePath) {
            Localizer.overrideDictionary = dictionary
        }

        // Randomly select the target shape
        let allShapes = ShapelyScene.Shape.allCases
        let selected = allShapes[Int.random(in: 0..<allShapes.count)]
        self.successShape = selected

        // Set localized text
        self.titleText = "Primary/Title".localized

        switch selected {
        case .circle:
            self.descriptionText = "Primary/DescriptionCircle".localized
        case .square:
            self.descriptionText = "Primary/DescriptionSquare".localized
        case .triangle:
            self.descriptionText = "Primary/DescriptionTriangle".localized
        case .pentagon:
            self.descriptionText = "Primary/DescriptionPentagon".localized
        }

        self.countdownLabelText = "Primary/Countdown".localized

        // Format initial countdown value
        let minutes = maxTime / 60
        let seconds = maxTime % 60
        self.countdownValueText = String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Scene Factory

    /// Creates or returns the cached SpriteKit scene. The scene is only created once to avoid
    /// recreation on SwiftUI re-renders.
    ///
    func makeScene(size: CGSize) -> ShapelyScene {
        if let existing = scene {
            return existing
        }

        let newScene = ShapelyScene(size: size)
        newScene.scaleMode = .resizeFill
        newScene.shapelySceneDelegate = self
        newScene.numberOfEachShape = numberOfEachShape
        scene = newScene
        return newScene
    }

    // MARK: - Timer

    /// Called once per second by the view's task to decrement the countdown.
    ///
    func tick() {
        guard supportsTimeOut, countdown > 0 else { return }

        countdown -= 1

        let minutes = countdown / 60
        let seconds = countdown % 60
        countdownValueText = String(format: "%02d:%02d", minutes, seconds)

        if countdown <= 0 {
            alertTitle = "TimeExpired/Title".localized
            alertMessage = "TimeExpired/Description".localized
            alertButtonTitle = "TimeExpired/OK".localized
            showAlert = true
        }
    }
}

// MARK: - ShapelySceneDelegate

extension ShapelyParentalGateViewModel: @preconcurrency ShapelySceneDelegate {

    func shapelyScene(_ scene: ShapelyScene, dropped shape: ShapelyScene.Shape?) -> Bool {
        guard let shape = shape else {
            return false
        }

        if shape == successShape {
            succeeded = true
            return true
        }

        failedAttempts += 1

        if failedAttempts >= maximumFailedAttempts {
            alertTitle = "TooManyAttempts/Title".localized
            alertMessage = "TooManyAttempts/Description".localized
            alertButtonTitle = "TooManyAttempts/OK".localized
            showAlert = true
        }

        return false
    }
}

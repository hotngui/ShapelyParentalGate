//
// Created by Joey Jarosz on 10/29/26.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import SpriteKit
import SwiftUI
import Testing
import UIKit
@testable import ShapelyParentalGate

/// The color overrides in `ShapelyParentalGateStaticConfiguration`, as resolved by `ShapelyParentalGateViewModel`. Every override
/// test uses a different color for each slot so a crossed wire fails.
///
@MainActor
struct ViewModelColorTests {
    @Test("Colors fall back to the original look when not configured") func defaultColors() {
        let viewModel = ShapelyParentalGateViewModel(configuration: .init())

        #expect(viewModel.backgroundColor == Color(red: 1.0, green: 0.742, blue: 0.230))
        #expect(viewModel.titleColor == .primary)
        #expect(viewModel.descriptionColor == .primary)
        #expect(viewModel.countdownColor == .red)
    }

    @Test("Configured colors replace the defaults") func configuredColors() {
        let configuration = ShapelyParentalGateStaticConfiguration(backgroundColor: .indigo,
                                                                   titleColor: .white,
                                                                   descriptionColor: .mint,
                                                                   countdownColor: .yellow)
        let viewModel = ShapelyParentalGateViewModel(configuration: configuration)

        #expect(viewModel.backgroundColor == .indigo)
        #expect(viewModel.titleColor == .white)
        #expect(viewModel.descriptionColor == .mint)
        #expect(viewModel.countdownColor == .yellow)
    }

    @Test("The target box keeps its gray colors when not configured") func defaultTargetColors() throws {
        let target = try presentedTargetNode(configuration: .init())

        #expect(Self.color(target.fillColor, matches: .systemGray2))
        #expect(Self.color(target.strokeColor, matches: .systemGray4))
    }

    @Test("Configured target colors reach the target box") func configuredTargetColors() throws {
        let configuration = ShapelyParentalGateStaticConfiguration(targetFillColor: Color(red: 0.2, green: 0.4, blue: 0.6),
                                                                   targetOutlineColor: Color(red: 0.9, green: 0.1, blue: 0.3))
        let target = try presentedTargetNode(configuration: configuration)

        #expect(Self.color(target.fillColor, matches: UIColor(red: 0.2, green: 0.4, blue: 0.6, alpha: 1.0)))
        #expect(Self.color(target.strokeColor, matches: UIColor(red: 0.9, green: 0.1, blue: 0.3, alpha: 1.0)))
    }

    // MARK: - Helpers

    /// Builds the scene the way the view does and presents it in an offscreen `SKView`, so `didMove(to:)` creates the real target
    /// node.
    ///
    private func presentedTargetNode(configuration: ShapelyParentalGateStaticConfiguration) throws -> SKShapeNode {
        let viewModel = ShapelyParentalGateViewModel(configuration: configuration)
        let scene = viewModel.makeScene(size: CGSize(width: 400, height: 800))
        let view = SKView(frame: CGRect(origin: .zero, size: scene.size))

        view.presentScene(scene)

        return try #require(scene.childNode(withName: "Target") as? SKShapeNode)
    }

    /// Compares RGBA components within a small tolerance. `==` won't do: SpriteKit hands back its own copy of the color (not the
    /// dynamic `systemGray2` object it was given), and SwiftUI stores components as `Float`.
    ///
    private static func color(_ actual: UIColor, matches expected: UIColor) -> Bool {
        guard let actualComponents = rgba(actual), let expectedComponents = rgba(expected) else {
            return false
        }

        return zip(actualComponents, expectedComponents).allSatisfy { abs($0 - $1) < 0.001 }
    }

    private static func rgba(_ color: UIColor) -> [CGFloat]? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return [red, green, blue, alpha]
    }
}

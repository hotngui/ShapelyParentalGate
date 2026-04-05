//
// Created by Joey Jarosz on 9/7/20.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import SwiftUI
import SpriteKit

/// A SwiftUI view that presents a parental gate challenge. The user must drag a randomly selected
/// shape to the target box to prove they are a parent/adult.
///
/// You can use this view directly or via the `.shapelyParentalGate()` view modifier.
///
public struct ShapelyParentalGateView: View {
    @State private var viewModel: ShapelyParentalGateViewModel
    @Environment(\.dismiss) private var dismiss

    private let onResult: (Bool) -> Void

    public init(
        configuration: ShapelyParentalGateStaticConfiguration = ShapelyParentalGateStaticConfiguration(),
        onResult: @escaping (Bool) -> Void
    ) {
        self._viewModel = State(initialValue: ShapelyParentalGateViewModel(configuration: configuration))
        self.onResult = onResult
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background color matching the original storyboard (#FFBD3A)
                Color(red: 1.0, green: 0.742, blue: 0.230)
                    .ignoresSafeArea()

                // SpriteKit scene
                SpriteView(scene: viewModel.makeScene(size: geometry.size),
                           options: [.allowsTransparency])
                    .ignoresSafeArea()

                // Overlay labels
                VStack {
                    Text(viewModel.titleText)
                        .font(.largeTitle)
                        .padding(.top, 10)

                    Text(viewModel.descriptionText)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer()

                    if viewModel.supportsTimeOut {
                        HStack(spacing: 2) {
                            Text(viewModel.countdownLabelText)
                                .font(.title3)
                                .foregroundStyle(.red)

                            Text(viewModel.countdownValueText)
                                .font(.title3)
                                .monospacedDigit()
                                .foregroundStyle(.red)
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .interactiveDismissDisabled()
        .task {
            guard viewModel.supportsTimeOut else { return }

            while viewModel.countdown > 0 && !viewModel.showAlert && !viewModel.succeeded {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                viewModel.tick()
            }
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button(viewModel.alertButtonTitle) {
                onResult(false)
                dismiss()
            }
        } message: {
            Text(viewModel.alertMessage)
        }
        .onChange(of: viewModel.succeeded) { _, newValue in
            if newValue {
                onResult(true)
                dismiss()
            }
        }
    }
}

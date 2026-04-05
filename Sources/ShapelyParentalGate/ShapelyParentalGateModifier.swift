//
// Created by Joey Jarosz on 9/7/20.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import SwiftUI

/// A view modifier that presents the ShapelyParentalGate as a full-screen cover.
///
struct ShapelyParentalGateModifier: ViewModifier {
    @Binding var isPresented: Bool
    let configuration: ShapelyParentalGateStaticConfiguration
    let onResult: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                ShapelyParentalGateView(
                    configuration: configuration,
                    onResult: { success in
                        isPresented = false
                        onResult(success)
                    }
                )
            }
    }
}

public extension View {

    /// Presents the ShapelyParentalGate as a full-screen cover.
    ///
    /// - Parameters:
    ///   - isPresented: A binding that controls whether the gate is shown.
    ///   - configuration: Optional configuration overrides. Defaults to standard configuration.
    ///   - onResult: Called when the gate completes. `true` if the user succeeded, `false` otherwise.
    ///
    func shapelyParentalGate(
        isPresented: Binding<Bool>,
        configuration: ShapelyParentalGateStaticConfiguration = ShapelyParentalGateStaticConfiguration(),
        onResult: @escaping (Bool) -> Void
    ) -> some View {
        modifier(ShapelyParentalGateModifier(
            isPresented: isPresented,
            configuration: configuration,
            onResult: onResult
        ))
    }
}

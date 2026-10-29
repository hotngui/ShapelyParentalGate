//
// Created by Joey Jarosz on 9/7/20.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import SwiftUI
import ShapelyParentalGate

struct ContentView: View {
    @State private var showParentalGate = false
    @State private var showCustomizedGate = false
    @State private var result: GateResult = .none

    private enum GateResult {
        case none
        case success
        case failure
    }

    private var configuration: ShapelyParentalGateStaticConfiguration {
        let filePath = Bundle.main.path(forResource: "ParentalGateStrings", ofType: "plist")

        return ShapelyParentalGateStaticConfiguration(
            localizedStringsFilePath: filePath,
            maximumFailedAttempts: 2,
            maximumTimeAllowed: 13
        )
    }

    /// The same gate restyled with every color override, to show how an app can match the gate to its own look.
    ///
    private var customizedConfiguration: ShapelyParentalGateStaticConfiguration {
        let filePath = Bundle.main.path(forResource: "ParentalGateStrings", ofType: "plist")

        return ShapelyParentalGateStaticConfiguration(
            localizedStringsFilePath: filePath,
            maximumFailedAttempts: 2,
            maximumTimeAllowed: 13,
            backgroundColor: Color(white: 0.15),
            titleColor: .white,
            descriptionColor: Color(white: 0.85),
            countdownColor: .orange,
            targetFillColor: Color(white: 0.3),
            targetOutlineColor: .orange
        )
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Parental Gate Example")
                .font(.title)

            Button("Show Parental Gate") {
                showParentalGate = true
            }
            .buttonStyle(.borderedProminent)

            Button("Show Customized Gate") {
                showCustomizedGate = true
            }
            .buttonStyle(.bordered)

            switch result {
            case .none:
                EmptyView()
            case .success:
                Text("Success! Gate passed.")
                    .foregroundStyle(.green)
                    .font(.headline)
            case .failure:
                Text("Failed. Access denied.")
                    .foregroundStyle(.red)
                    .font(.headline)
            }
        }
        .shapelyParentalGate(
            isPresented: $showParentalGate,
            configuration: configuration
        ) { success in
            result = success ? .success : .failure
        }
        .shapelyParentalGate(
            isPresented: $showCustomizedGate,
            configuration: customizedConfiguration
        ) { success in
            result = success ? .success : .failure
        }
    }
}

#Preview {
    ContentView()
}

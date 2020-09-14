//  
// Created by Joey Jarosz on 9/7/20.
// Copyright © 2020 hot-n-GUI, LLC. All rights reserved.
//


import UIKit
import ShapelyParentalGate

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var filePath: String?

        if let path = Bundle.main.path(forResource: "ParentalGateStrings", ofType: "plist") {
            filePath = path
        }

        ShapelyParentalGate.configure(
            ShapelyParentalGateStaticConfiguration(localizedStringsFilePath: filePath,
                                                   maximumFailedAttempts: 2,
                                                   maximumTimeAllowed: 13)
        )
    }

    @IBAction
    private func buttonTapped(_ sender: UIButton) {
        present(ShapelyParentalGate.viewController(), animated: true)
    }
}


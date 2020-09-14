//
// Created by Joey Jarosz on 9/7/20.
// Copyright © 2020 hot-n-GUI, LLC. All rights reserved.
//

import UIKit
import SpriteKit

///
public protocol ShapelyParentalGateDelegate: class {
    func shapelyParentalGate(_ shapelyParentGate: ShapelyParentalGate, success: Bool)
}

/// This class represents a UIViewController that when presented requires the user to grab the specified shape and drop it into the target box. The shape to be grabbed is
/// randomly selected from a collection of shapes each time a new instance of this class is created. Not only does the user need to be able to read but they also need the dexterity
/// to grab and drag the shape.
///
/// The caller can also control various details via the _ShapelyParentalGateStaticConfiguration_ struct to fit their individual requirements.
/// * A Plist file that contains customized and potentially localized strings
/// * The maximum number of attempts at dropping a shape into the target box a user is allowed
/// * The maximum amount of time the user has to complete the task
/// * The number of copies of each shape to be generated.
///
public class ShapelyParentalGate: UIViewController, ShapelySceneDelegate {
    @IBOutlet private weak var skView: SKView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var countdownLabel: UILabel!
    @IBOutlet private weak var countdownValueLabel: UILabel!

    private enum Constants {
        static var maximumFailedAttempts = 2
        static var maximumTimeAllowed = 10
        static var numberOfEachShape = 2
        static var supportsTimeOut = true
    }

    private static var configuration: ShapelyParentalGateStaticConfiguration?

    private lazy var countdown: Int = {
        return Constants.maximumTimeAllowed
    }()

    private var countdownTimer: Timer?
    private var alreadySetup = false
    private var failedAttempts = 0
    private var successShape: ShapelyScene.Shape?
    private var successDescription: String?

    public var delegate: ShapelyParentalGateDelegate?

    /// A static method that returns a new instance of this class each time its called.
    ///
    public static func viewController() -> ShapelyParentalGate {
        let storyboard = UIStoryboard(name: "ShapelyParentalGate", bundle: .module)

        guard let vc = storyboard.instantiateInitialViewController() as? ShapelyParentalGate else {
            preconditionFailure("Something went terribly wrong trying to find the view controller.")
        }

        vc.modalPresentationStyle = .formSheet
        vc.isModalInPresentation = true

        //
        if let configuration = Self.configuration {
            if let filePath = configuration.localizedStringsFilePath {
                if let dictionary = NSDictionary(contentsOfFile: filePath) {
                    Localizer.overrideDictionary = dictionary
                }
            }

            if let maximumFailedAttempts = configuration.maximumFailedAttempts {
                Constants.maximumFailedAttempts = maximumFailedAttempts
            }

            if let maximumTimeAllowed = configuration.maximumTimeAllowed {
                Constants.maximumTimeAllowed = maximumTimeAllowed
            }

            if let numberOfEachShape = configuration.numberOfEachShape {
                Constants.numberOfEachShape = numberOfEachShape
            }

            if let supportsTimeOut = configuration.supportsTimeOut {
                Constants.supportsTimeOut = supportsTimeOut
            }
        }

        return vc
    }

    //MARK: - View Lifecycle

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    ///
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupSuccessShape()

        titleLabel.text = "ViewController/Title".localized
        descriptionLabel.text = successDescription

        if Constants.supportsTimeOut {
            countdownLabel.text = "ViewController/Countdown".localized
            countdownValueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: countdownValueLabel.font.pointSize, weight: .medium)

            setupCountdownTimer()
        } else {
            countdownLabel.isHidden = true
            countdownValueLabel.isHidden = true
        }
    }

    ///
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We have to remove any gesture recognizers that may have been added to this view controlle otherwise, when the user
        // tries to drag a shape around. This primarly wants to get rid of the swipe gestured that would normally allow a
        // presented view controller to be dismissed.
        //
        presentationController?.presentedView?.gestureRecognizers?.forEach {
            $0.isEnabled = false
        }

        // The first time through we need to setup our scene. This has to be done here because we need to know the actual
        // size of the view controller's view since we want the scene to cover that entire area.
        //
        if alreadySetup == false {
            alreadySetup = true
            
            skView.frame = view.bounds
            skView.ignoresSiblingOrder = true

            let scene = ShapelyScene(size: view.bounds.size)
            scene.scaleMode = .aspectFill
            scene.shapelySceneDelegate = self
            scene.numberOfEachShape = Constants.numberOfEachShape

            #if DEBUG
                skView.showsFPS = true
                skView.showsNodeCount = true
            #endif

            skView.presentScene(scene)
        }
    }

    /// We need to do some cleanup when this view controller is dismissed, so when it disappears we do the following.
    /// + Clear out the countdown timer
    /// +  Set the view's scene to nothing, so the one we did originally set can be released.
    ///
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        countdownTimer?.invalidate()
        countdownTimer = nil

        skView.presentScene(nil)
    }

    /// We need to find out when the user changes the font size dynamically, so we can correctly update our countdown string which uses a customize font.
    ///
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        countdownValueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: countdownValueLabel.font.pointSize, weight: .medium)
    }

    //MARK: - Public Methods

    /// This method allows the caller to override a bunch of default configuration information for this class. See the _ShapelyParentalGateStaticConfiguration_ class
    /// for details.
    ///
    /// - Parameter configuration: A instance of a configuration object to be applied to all instances of this class going forward.
    ///
    public static func configure(_ configuration: ShapelyParentalGateStaticConfiguration) {
        Self.configuration = configuration
    }

    //MARK: - Private Methods

    /// Randomly selects which shape the user needs to grab, drag, and drop in the target box. Also sets the visible string to let the user know which shape
    /// they need to grab.
    ///
    private func setupSuccessShape() {
        let count = ShapelyScene.Shape.allCases.count
        let index = Int.random(in: 0..<count)

        switch index {
        case 0:
            successShape = .circle
            successDescription = "ViewController/DescriptionCircle".localized

        case 1:
            successShape = .square
            successDescription = "ViewController/DescriptionSquare".localized

        case 2:
            successShape = .triangle
            successDescription = "ViewController/DescriptionTriangle".localized

        default:
            successShape = .pentagon
            successDescription = "ViewController/DescriptionPentagon".localized
        }
    }

    /// If the caller wants to force a correct result before a specified amount of time we need to setup a time to countdown and to display the current value.
    ///
    private func setupCountdownTimer() {
        updateCountdownValue()

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
            guard let self = self else {
                return
            }

            self.countdown -= 1
            self.updateCountdownValue()

            if self.countdown <= 0 {
                timer.invalidate()
                self.showTimeExpired()
            }
        }
    }

    /// Update the countdown label using a format that looks like "00:00"
    ///
    private func updateCountdownValue() {
        let minutes = countdown / 60
        let seconds = countdown % 60

        countdownValueLabel.text = "\(String(format: "%02d", minutes)):\(String(format: "%02d", seconds))"
    }

    ///
    private func showTimeExpired() {
        let alert = UIAlertController(title: "TimeExpired/Title".localized,
                                      message: "TimeExpired/Description".localized,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "TimeExpired/OK".localized, style: .default, handler: { _ in
            self.delegate?.shapelyParentalGate(self, success: false)
            self.dismiss(animated: true)
        }))

        present(alert, animated: true)
    }

    ///
    private func showTooManyAttempts() {
        let alert = UIAlertController(title: "TooManyAttempts/Title".localized,
                                      message: "TooManyAttempts/Description".localized,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "TooManyAttempts/OK".localized, style: .default, handler: { _ in
            self.delegate?.shapelyParentalGate(self, success: false)
            self.dismiss(animated: true)
        }))

        present(alert, animated: true)
    }

    //MARK: - ShapelySceneDelegate Protocol

    func shapelyScene(_ scene: ShapelyScene, dropped shape: ShapelyScene.Shape?) -> Bool {
        guard let shape = shape else {
            return false
        }

        if shape == successShape {
            delegate?.shapelyParentalGate(self, success: true)
            dismiss(animated: true)
            return true
        }

        failedAttempts += 1

        if failedAttempts >= Constants.maximumFailedAttempts {
            showTooManyAttempts()
        }

        return false
    }
}

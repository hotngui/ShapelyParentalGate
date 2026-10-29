//
// Created by Joey Jarosz on 9/12/20.
// Copyright © 2020-2026 hot-n-GUI, LLC. All rights reserved.
//

import SwiftUI

/// This struct allows for the overriding of default configuraiton information that affects the look and behavior of the
/// _Parental Gate_.
///
public struct ShapelyParentalGateStaticConfiguration: Sendable {
    let localizedStringsFilePath: String?
    let maximumFailedAttempts: Int?
    let supportsTimeOut: Bool?
    let maximumTimeAllowed: Int?
    let numberOfEachShape: Int?
    let backgroundColor: Color?
    let titleColor: Color?
    let descriptionColor: Color?
    let countdownColor: Color?
    let targetFillColor: Color?
    let targetOutlineColor: Color?

    /// You initialize the struct with only values you are interested in overriding from their defaults. Being a struct, when you
    /// pass an instance to the configuration method it is copied, so it makes no sense to modify it afterwards. For this reasons,
    /// there are no public accessors to the individual values.
    ///
    /// If you are specifying a PLIST file to override the defaults wtih your own values and translations the file must match the
    /// format of the default file shipped with this package. __If you only want to change a few strings it is okey only include
    /// those as long as the format of the dictionaries remains the same.__
    ///
    /// Each color left `nil` keeps the gate's original look. Checking that your text colors have enough contrast against your
    /// background color is up to you.
    ///
    /// - Parameters:
    ///   - localizedStringsFilePath: A string pointing to the location of the PLIST file that contains your overrides and
    ///     translations for all the user visible strings.
    ///   - maximumFailedAttempts: This is the number of times the child can try to get the right answer before its considered a
    ///     failed attempt.
    ///   - supportsTimeOut: If true the user will have a limited amount of time to finish the task.
    ///   - maximumTimeAllowed: This is the amount of time, in seconds, that the child has to correctly answer before its considered
    ///     a failed attempt.
    ///   - numberOfEachShape: This is the number of each shape that will be created and bounced around.
    ///   - backgroundColor: The color behind the bouncing shapes. Defaults to orange (`#FFBD3A`).
    ///   - titleColor: The color of the title text. Defaults to `.primary`.
    ///   - descriptionColor: The color of the text telling the user which shape to drag. Defaults to `.primary`.
    ///   - countdownColor: The color of the countdown label and its time value. Defaults to `.red`.
    ///   - targetFillColor: The fill color of the target box the shape is dropped on. Defaults to `systemGray2`.
    ///   - targetOutlineColor: The color of the target box's outline and glow. Defaults to `systemGray4`.
    ///
    public init(
        localizedStringsFilePath: String? = nil,
        maximumFailedAttempts: Int? = nil,
        supportsTimeOut: Bool? = true,
        maximumTimeAllowed: Int? = nil,
        numberOfEachShape: Int? = nil,
        backgroundColor: Color? = nil,
        titleColor: Color? = nil,
        descriptionColor: Color? = nil,
        countdownColor: Color? = nil,
        targetFillColor: Color? = nil,
        targetOutlineColor: Color? = nil
    ) {
        self.localizedStringsFilePath = localizedStringsFilePath
        self.maximumFailedAttempts = maximumFailedAttempts
        self.supportsTimeOut = supportsTimeOut
        self.maximumTimeAllowed = maximumTimeAllowed
        self.numberOfEachShape = numberOfEachShape
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.descriptionColor = descriptionColor
        self.countdownColor = countdownColor
        self.targetFillColor = targetFillColor
        self.targetOutlineColor = targetOutlineColor
    }
}

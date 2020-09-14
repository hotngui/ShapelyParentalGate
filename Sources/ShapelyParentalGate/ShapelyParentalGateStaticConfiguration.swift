//  
// Created by Joey Jarosz on 9/12/20.
// Copyright © 2020 hot-n-GUI, LLC. All rights reserved.
//

import Foundation

/// This struct allows for the overriding of default configuraiton information that affects the look and behavior of the _Parental Gate_.
///
public struct ShapelyParentalGateStaticConfiguration {
    let localizedStringsFilePath: String?
    let maximumFailedAttempts: Int?
    let supportsTimeOut: Bool?
    let maximumTimeAllowed: Int?
    let numberOfEachShape: Int?

    /// You initialize the struct with only values you are interested in overriding from their defaults. Being a struct, when you pass an instance to the configuration
    /// method it is copied, so it makes no sense to modify it afterwards. For this reasons, there are no public accessors to the individual values.
    ///
    /// If you are specifying a PLIST file to override the defaults wtih your own values and translations the file must match the format of the default file shipped
    /// with this package. __If you only want to change a few strings it is okey only include those as long as the format of the dictionaries remains the same.__
    ///
    /// - Parameters:
    ///   - localizedStringsFilePath: A string pointing to the location of the PLIST file that contains your overrides and translations for all the user visible strings.
    ///   - maximumFailedAttempts: This is the number of times the child can try to get the right answer before its considered a failed attempt.
    ///   - supportsTimeOut: If true the user will have a limited amount of time to finish the task.
    ///   - maximumTimeAllowed: This is the amount of time, in seconds, that the child has to correctly answer before its considered a failed attempt.
    ///   - numberOfEachShape: This is the number of each shape that will be created and bounced around.
    ///
    public init(localizedStringsFilePath: String? = nil, maximumFailedAttempts: Int? = nil, supportsTimeOut: Bool? = true, maximumTimeAllowed: Int? = nil, numberOfEachShape: Int? = nil) {
        self.localizedStringsFilePath = localizedStringsFilePath
        self.maximumFailedAttempts = maximumFailedAttempts
        self.supportsTimeOut = supportsTimeOut
        self.maximumTimeAllowed = maximumTimeAllowed
        self.numberOfEachShape = numberOfEachShape
    }
}


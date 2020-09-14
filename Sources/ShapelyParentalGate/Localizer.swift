//
// Created by Joey Jarosz on 9/10/20.
// Copyright © 2020 hot-n-GUI, LLC. All rights reserved.
//

import Foundation

/// A Utility class that allows us to support localization of our visible strings where the user of this package gets to define the different localizations.
///
class Localizer {
    /// Singleton
    static let shared = Localizer()

    /// Optional dictionary to look in first for a specified string, before looking at the default PLIST file.
    static var overrideDictionary: NSDictionary?

    /// The default dictionary containing default strings...
    lazy var localizableDictionary: NSDictionary = {
        if let path = Bundle.module.path(forResource: "DefaultLocalizedStrings", ofType: "plist") {
            if let dictionary = NSDictionary(contentsOfFile: path) {
                return dictionary
            }
        }
        preconditionFailure()
    }()

    /// Prevent callers from creating their own instances of this class.
    ///
    private init() {
    }

    /// This method does the look up of the specified string using the following steps:
    ///  * Split the input string to see if it represents a simple hierarchy. Right now it only supports Category/Key and assumes both levels exist.
    ///  * Attempt to lookup the value in the override dictionary if it exists
    ///  * Attempt to looup the value if the default dictionary
    ///  * Return an obvious default if not found in either dictionary.
    ///
    /// - Parameter key: The string to be looked up
    /// - Returns: The found value for the specified key, else a default value.
    ///
    fileprivate func localize(key: String) -> String {
        let substrings = key.split(separator: "/")

        if substrings.count != 2 {
            assertionFailure()
        }

        let category = String(substrings[0])
        let name = String(substrings[1])

        if let dict1 = Localizer.overrideDictionary?.value(forKey: category) as? NSDictionary,
           let dict2 = dict1.value(forKey: name) as? NSDictionary,
           let localizedString = dict2.value(forKey: "value") as? String {
            return localizedString
        }

        if let dict1 = localizableDictionary.value(forKey: category) as? NSDictionary,
           let dict2 = dict1.value(forKey: name) as? NSDictionary,
           let localizedString = dict2.value(forKey: "value") as? String {
            return localizedString
        }

        return "MISSING STRING"
    }
}

/// To access this functionality you simply use a string like _"TooManyFailures/Title".localized_
///
extension String {
    var localized: String {
        return Localizer.shared.localize(key: self)
    }
}

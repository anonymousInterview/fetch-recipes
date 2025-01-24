//
//  FetchRecipes+Logger.swift
//  Networking
//
//

import OSLog

public extension Logger {
    /// All logs related to tracking and analytics.
    static let tracking = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "tracking")
}

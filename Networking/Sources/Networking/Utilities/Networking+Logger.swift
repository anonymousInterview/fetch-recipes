//
//  Networking+Logger.swift
//  Networking
//
//

import OSLog

public extension Logger {
    /// All logs related to tracking
    static let networking = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "tracking")
}

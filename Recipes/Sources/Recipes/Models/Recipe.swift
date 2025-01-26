//
//  Recipe.swift
//  Recipes
//
//

import Foundation
import Networking
import OSLog

/// A model representation of Recipe
public struct Recipe: Decodable, Identifiable, Sendable {
    let uuid: String
    let name: String
    let cuisine: Cuisine
    let photoUrlLarge: URL?
    let photoUrlSmall: URL?
    let sourceUrl: URL?
    let youtubeUrl: URL?

    /// A computed property that `Recipe` to conform to Identifiable
    public var id: String {
        uuid
    }

    public enum Cuisine: String, Decodable, Equatable, Sendable {
        case american
        case british
        case canadian
        case croatian
        case french
        case greek
        case italian
        case malaysian
        case polish
        case portuguese
        case tunisian
        case russian
        case other

        /// Human readable transformation
        var displayName: String {
            rawValue.capitalized
        }

        /// This custom decoder allows us to defend the client from backend changes that it
        /// cannot handle. You could also make the case that if you can't enumerate all the values
        /// you may as well not have an enum. I find that the benefits of being able to strongly type strings
        /// brings enough developer value for the client to enumerate when possible... while also
        /// protecting against potential breaking API changes.
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self).lowercased()
            if let cuisine = Cuisine(rawValue: value) {
                self = cuisine
            } else {
                Logger.networking.error("The client cannot decode the following value for cuisine: \(value).")
                self = .other
            }
        }
    }
}

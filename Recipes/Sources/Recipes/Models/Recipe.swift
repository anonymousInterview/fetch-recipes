//
//  Recipe.swift
//  Recipes
//
//

import OSLog
import Foundation
import Networking

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
        
        /// This custom decoder allows us to defend the client from backend changes that it
        /// cannot handle.
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self).lowercased()
            if let cuisine = Cuisine(rawValue: value) {
                self = cuisine
            } else {
                Logger().error("The client cannot decode the following value for cuisine: \(value).")
                self = .other
            }
        }
        
    }
}

extension Recipe {
    var displayCuisine: String {
        cuisine.rawValue.capitalized
    }
}

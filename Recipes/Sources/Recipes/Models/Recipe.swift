//
//  Recipe.swift
//  Recipes
//
//

import Foundation

public struct Recipe: Decodable, Identifiable, Sendable {
    let uuid: String
    let name: String
    let cuisine: Cuisine
    let photoURLLarge: URL?
    let photoURLSmall: URL?
    let sourceURL: URL?
    let youtubeURL: URL?
    
    /// A computed property that `Recipe` to conform to Identifiable
    public var id: String {
        uuid
    }
    
    public enum Cuisine: Decodable, Equatable, Sendable {
        case american
        case british
        case canadian
        case malaysian
        case tunisian
        case other(String)
        
        /// This custom decoder allows us to defend the client from backend changes that it
        /// cannot handle.
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self).lowercased()
            
            switch value {
            case "american": self = .american
            case "british": self = .british
            case "canadian": self = .canadian
            case "malaysian": self = .malaysian
            case "tunisian": self = .tunisian
            default:
                // TODO: Figure out how to send an alert
                // assertionFailure("The client cannot decode the following value for cuisine: \(value).")
                self = .other(value)
            }
        }
        
    }
}

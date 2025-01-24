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
                Logger.tracking.error("The client cannot decode the following value for cuisine: \(value).")
                self = .other(value)
            }
        }
        
    }
}

//
//  RecipeService.swift
//  Recipes
//
//

import Foundation
import Networking

enum RecipeService {
    struct RecipeResponse: Decodable {
        let recipes: [Recipe]
    }

    static func fetchRecipes(client: HTTPClient) async throws -> [Recipe] {
        guard let url = URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json") else {
            throw URLError(.badURL)
        }
        let responseData = try await client.get(url: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let recipeResponse = try decoder.decode(RecipeService.RecipeResponse.self, from: responseData)
        return recipeResponse.recipes
    }
}

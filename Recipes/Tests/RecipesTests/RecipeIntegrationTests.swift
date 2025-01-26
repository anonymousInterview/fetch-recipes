import Testing
import Foundation
@testable import Recipes
@testable import Networking

struct ReceipeIntegrationTests {
    @Test func validResponse() async throws {
        let client = DefaultHTTPClient()
        let responseData = try await client.get(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!)
        let decoder = JSONDecoder()
        let recipeResponse = try decoder.decode(RecipeService.RecipeResponse.self, from: responseData)
        #expect(recipeResponse.recipes.count == 63)
    }
    
    @Test func emptyResponse() async throws {
        let client = DefaultHTTPClient()
        let responseData = try await client.get(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!)
        let decoder = JSONDecoder()
        let recipeResponse = try decoder.decode(RecipeService.RecipeResponse.self, from: responseData)
        #expect(recipeResponse.recipes.isEmpty)
    }
    
    @Test func malformatedResponse() async throws {
        let client = DefaultHTTPClient()
        let responseData = try await client.get(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!)
        let decoder = JSONDecoder()
        #expect((try? decoder.decode(RecipeService.RecipeResponse.self, from: responseData)) == nil)
    }
}

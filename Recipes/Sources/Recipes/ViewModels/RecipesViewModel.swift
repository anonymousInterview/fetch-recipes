//
//  RecipesViewModel.swift
//  Recipes
//
//

import SwiftUI
import Networking

@MainActor
public class RecipesViewModel: ObservableObject {
    let httpClient: HTTPClient
    
    // We're reading directly from the Recipe backend model
    // instead of creating a viewModel. This was an intentional
    // decision to minimize abstraction layers. If we needed
    // to do more data transformations, a viewModel would be
    // more appropriate.
    @Published var recipes: [Recipe] = []
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func fetchRecipes() async throws {
        let recipes = try await RecipeService.fetchRecipes(client: httpClient)
        self.recipes = recipes
    }
}

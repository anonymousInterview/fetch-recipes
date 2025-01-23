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
    
    @Published var recipes: [Recipe] = []
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func fetchRecipes() async {
        do {
            let recipes = try await RecipeService.fetchRecipes(client: httpClient)
            self.recipes = recipes
        } catch {
            // TODO: throw error
        }
    }
}

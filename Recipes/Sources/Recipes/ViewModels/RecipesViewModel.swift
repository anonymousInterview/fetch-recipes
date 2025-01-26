//
//  RecipesViewModel.swift
//  Recipes
//
//

import Networking
import SwiftUI

/// A viewModel for `RecipesView`
@MainActor
public class RecipesViewModel: ObservableObject {
    let httpClient: HTTPClient

    // We're reading directly from the Recipe backend model
    // instead of creating a viewModel. This was an intentional
    // decision to minimize abstraction layers. If we needed
    // to do more data transformations, a viewModel would be
    // more appropriate.
    @Published var recipes: [Recipe] = []

    /// An initializer for `RecipesViewModel`
    /// - Parameter httpClient: Requires an implementation of `HTTPClient`
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func fetchRecipes() async throws {
        recipes = try await RecipeService.fetchRecipes(client: httpClient)
    }
}

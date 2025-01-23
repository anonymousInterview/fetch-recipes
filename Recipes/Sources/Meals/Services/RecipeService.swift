//
//  RecipeService.swift
//  Recipes
//
//  Created by Ulises Giacoman on 1/22/25.
//

import Networking

struct RecipeService {
    struct RecipeResponse: Decodable {
        let recipes: [Recipe]
    }
    
    func fetchRecipes(client: HTTPClient) -> [Recipe] {
        return []
    }
}

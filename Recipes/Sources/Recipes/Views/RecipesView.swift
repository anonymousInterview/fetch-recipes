//
//  RecipesView.swift
//  Recipes
//
//

import SwiftUI

public struct RecipesView: View {
    @ObservedObject private var viewModel: RecipesViewModel
    
    public var body: some View {
        List {
            ForEach(viewModel.recipes) { recipe in
                Text(recipe.name)
            }
        }.task {
            await viewModel.fetchRecipes()
        }
    }
    
    public init(viewModel: RecipesViewModel) {
        self.viewModel = viewModel
    }
}

// TODO: Fix preview
//#Preview {
//    class MockHTTPClient: HTTPClient {}
//    let mockHTTPClient = MockHTTPClient()
//    
//    Group {
//        RecipesView(viewModel: RecipesViewModel(httpClient: mockHTTPClient))
//    }
//}

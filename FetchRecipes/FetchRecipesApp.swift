//
//  FetchRecipesApp.swift
//  FetchRecipes
//
//

import SwiftUI
import Networking
import Recipes

@main
struct FetchRecipesApp: App {
    let client: HTTPClient
    let imageLoader: ImageLoader
    let viewModel: RecipesViewModel
    
    var body: some Scene {
        WindowGroup {
            RecipesView(viewModel: viewModel, imageLoader: imageLoader)
        }
    }
    
    /// App Conformance
    init() {
        self.client = DefaultHTTPClient()
        self.imageLoader = DefaultImageLoader(cache: DefaultDataCache(), client: client)
        self.viewModel = RecipesViewModel(httpClient: client)
    }
}

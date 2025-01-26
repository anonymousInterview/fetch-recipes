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
    let dataCache: DataCache = DataCache()
    let client: HTTPClient = DefaultHTTPClient()
    let imageLoader: ImageLoader
    let viewModel: RecipesViewModel
    
    var body: some Scene {
        WindowGroup {
            RecipesView(viewModel: viewModel, imageLoader: imageLoader)
        }
    }
    
    init() {
        self.imageLoader = ImageLoader(cache: dataCache)
        self.viewModel = RecipesViewModel(httpClient: client)
    }
}

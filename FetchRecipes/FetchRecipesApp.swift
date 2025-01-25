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
    
    var body: some Scene {
        WindowGroup {
            RecipesView(viewModel: RecipesViewModel(httpClient: client), imageLoader: imageLoader)
        }
    }
    
    init() {
        self.imageLoader = ImageLoader(cache: dataCache)
    }
}

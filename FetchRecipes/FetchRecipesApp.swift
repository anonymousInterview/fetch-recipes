//
//  FetchRecipesApp.swift
//  FetchRecipes
//
//

import Networking
import Recipes
import SwiftUI

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
        client = DefaultHTTPClient()
        imageLoader = DefaultImageLoader(cache: DefaultDataCache(), client: client)
        viewModel = RecipesViewModel(httpClient: client)
    }
}

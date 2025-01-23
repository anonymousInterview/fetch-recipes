//
//  ContentView.swift
//  FetchRecipes
//
//

import SwiftUI
import Recipes
import Networking

struct ContentView: View {
    var body: some View {
        // TODO: Think more about navigation, Coordinator, ownership
        RecipesView(viewModel: RecipesViewModel(httpClient: DefaultHTTPClient()))
    }
}

#Preview {
    ContentView()
}

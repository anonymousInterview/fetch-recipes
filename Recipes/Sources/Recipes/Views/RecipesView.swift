//
//  RecipesView.swift
//  Recipes
//
//

import SwiftUI
import Networking

public struct RecipesView: View {
    let imageLoader: ImageLoader
    @ObservedObject private var viewModel: RecipesViewModel
    
    public var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.recipes) { recipe in
                    VStack(alignment: .leading) {
                        Text(recipe.name).font(.headline)
                        Text(recipe.displayCuisine).font(.subheadline)
                        actionButtons(sourceUrl: recipe.sourceUrl, youtubeUrl: recipe.youtubeUrl)
                        AsynchronousImage(url: recipe.photoUrlSmall, imageLoader: imageLoader)
                            .accessibilityHidden(true)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }.task {
                await viewModel.fetchRecipes()
            }
            .navigationTitle("Recipes")
        }
    }
    
    func actionButtons(sourceUrl: URL?, youtubeUrl: URL?) -> some View {
        HStack(alignment: .center) {
            Button {
                UIApplication.shared.open(sourceUrl!)
            } label: {
                Image(systemName: "list.dash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("Open Recipe in Browser")
            
            Button {
                UIApplication.shared.open(youtubeUrl!)
            } label: {
                Image(systemName: "video")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            .accessibilityLabel("View Recipe on Youtube")
        }
    }
    
    public init(viewModel: RecipesViewModel, imageLoader: ImageLoader) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
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

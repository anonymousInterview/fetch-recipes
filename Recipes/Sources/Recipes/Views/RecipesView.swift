//
//  RecipesView.swift
//  Recipes
//
//

import SwiftUI
import Networking

public struct RecipesView: View {
    enum ViewState {
        case loading
        case loaded([Recipe])
        case error
    }
    
    let imageLoader: ImageLoader
    @ObservedObject private var viewModel: RecipesViewModel
    @State var state: ViewState = .loading
    
    public var body: some View {
        NavigationStack {
            List {
                switch state {
                case .loading:
                    loadingView
                case .loaded(let recipes):
                    ForEach(recipes) { recipe in
                        recipeView(recipe: recipe)
                    }
                case .error:
                    errorView
                }
            }
            .refreshable {
                await fetchRecipes()
            }
            .navigationTitle("Recipes")
        }
        .task {
            await fetchRecipes()
        }
    }
    
    var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
    }
    
    var errorView: some View {
        Text("⚠️ Error, please try again. ⚠️ ")
            .frame(maxWidth: .infinity)
    }
    
    func fetchRecipes() async {
        state = .loading
        do {
            try await viewModel.fetchRecipes()
            state = .loaded(viewModel.recipes)
        } catch {
            state = .error
        }
    }
    
    @ViewBuilder
    func recipeView(recipe: Recipe) -> some View {
        VStack(alignment: .leading) {
            Text(recipe.name)
                .font(.headline)
            Text(recipe.displayCuisine)
                .font(.subheadline)
            actionButtons(sourceUrl: recipe.sourceUrl, youtubeUrl: recipe.youtubeUrl)
            AsynchronousImage(
                url: recipe.photoUrlSmall,
                imageLoader: imageLoader,
                placeholder: Image(systemName: "fork.knife")
            )
            .accessibilityHidden(true) // Since we don't have alt text,
                                       // hiding images from screen readers.
        }
        .buttonStyle(PlainButtonStyle()) // Prevent cell from swallowing tap gestures
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

//
//  RecipesView.swift
//  Recipes
//
//

import SwiftUI
import Networking

/// A view that displays a list of Recipes.
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
                    if !recipes.isEmpty {
                        ForEach(recipes) { recipe in
                            recipeView(recipe: recipe)
                        }
                    } else {
                        Text("Nothing to see here folks.")
                            .frame(maxWidth: .infinity)
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
        HStack(alignment: .top, spacing: 12) {
            AsynchronousImage(
                url: recipe.photoUrlSmall,
                imageLoader: imageLoader,
                placeholder: Image(systemName: "fork.knife")
            )
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 4, height: 4)))
            .frame(width: 80, height: 80)
            // Since we don't have alt text, hiding images from screen readers.
            .accessibilityHidden(true)
            VStack(alignment: .leading) {
                Text(recipe.name)
                    .font(.headline)
                Text(recipe.cuisine.displayName)
                    .font(.subheadline)
                actionButtons(sourceUrl: recipe.sourceUrl, youtubeUrl: recipe.youtubeUrl)
            }
        }
        .buttonStyle(PlainButtonStyle()) // Prevent cell from swallowing tap gestures
    }
    
    func actionButtons(sourceUrl: URL?, youtubeUrl: URL?) -> some View {
        HStack(alignment: .center) {
            if let sourceUrl {
                Button {
                    UIApplication.shared.open(sourceUrl)
                } label: {
                    Image(systemName: "list.dash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Open Recipe in Browser")
            }
            if let youtubeUrl {
                Button {
                    UIApplication.shared.open(youtubeUrl)
                } label: {
                    Image(systemName: "video")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("View Recipe on Youtube")
            }
        }
    }
    
    public init(viewModel: RecipesViewModel, imageLoader: ImageLoader) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
    }
}

#Preview("Loaded State") {
    let mockHTTPClient = MockHTTPClient()
    let viewModel = RecipesViewModel(httpClient: mockHTTPClient)
    return RecipesView(viewModel: viewModel, imageLoader: MockImageLoader())
}

#Preview("Error State") {
    let mockHTTPClient = MockHTTPClient(customResponse: Data())
    let viewModel = RecipesViewModel(httpClient: mockHTTPClient)
    return RecipesView(viewModel: viewModel, imageLoader: MockImageLoader())
}

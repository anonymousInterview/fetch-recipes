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
        List {
            ForEach(viewModel.recipes) { recipe in
                VStack(alignment: .leading) {
                    Text(recipe.name)
                    AsynchronousImage(url: recipe.photoUrlSmall, imageLoader: imageLoader)
                        .frame(width: 80, height: 80)
                }
            }
        }.task {
            await viewModel.fetchRecipes()
        }
    }
    
    public init(viewModel: RecipesViewModel, imageLoader: ImageLoader) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
    }
}

struct AsynchronousImage: View {
    let imageLoader: ImageLoader
    let url: URL?
    @State private var image: UIImage? = nil
    
    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .task {
            if let url {
                await fetchImage(url: url)
            }
        }
    }
    
    func fetchImage(url: URL) async {
        do {
            image = try await imageLoader.retrieveImage(for: url)
        } catch {
            print("Failed to download image from \(url): \(error)")
        }
    }
    
    public init(url: URL?, imageLoader: ImageLoader) {
        self.url = url
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

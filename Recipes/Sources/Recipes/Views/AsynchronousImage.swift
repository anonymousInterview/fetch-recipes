//
//  AsynchronousImage.swift
//  Recipes
//
//

import SwiftUI
import Networking

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
                    .frame(width: 200, height: 200)
            } else {
                Image(systemName: "fork.knife")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(.gray)
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

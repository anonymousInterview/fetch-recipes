//
//  AsynchronousImage.swift
//  Recipes
//
//

import SwiftUI
import OSLog

public struct AsynchronousImage: View {
    private let imageLoader: ImageLoader
    private let url: URL?
    private let placeholder: Image
    @State private var image: UIImage? = nil
    
    public var body: some View {
        HStack {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                } else {
                    placeholder
                        .resizable()
                }
            }
            .scaledToFit()
            .frame(width: 200, height: 200)
        }
        .task {
            if let url {
                await fetchImage(url: url)
            }
        }
    }
    
    public func fetchImage(url: URL) async {
        do {
            image = try await imageLoader.retrieveImage(for: url)
        } catch {
            Logger.networking.error("Failed to retrieve image for: \(url). Error: \(error.localizedDescription)")
        }
    }
    
    public init(url: URL?, imageLoader: ImageLoader, placeholder: Image) {
        self.url = url
        self.imageLoader = imageLoader
        self.placeholder = placeholder
    }
}

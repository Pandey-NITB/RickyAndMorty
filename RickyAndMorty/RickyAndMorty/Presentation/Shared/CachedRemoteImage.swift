//
//  CachedRemoteImage.swift
//  RickyAndMorty
//
//  Created by Prashant Pandey on 12/05/26.
//


import Combine
import Foundation
import SwiftUI
import UIKit

struct CachedRemoteImage<Content: View, Placeholder: View>: View {
    let urlString: String
    let content: (Image) -> Content
    let placeholder: (Bool) -> Placeholder

    @StateObject private var loader: CachedRemoteImageLoader

    init(
        urlString: String,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping (Bool) -> Placeholder
    ) {
        self.urlString = urlString
        self.content = content
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: CachedRemoteImageLoader(urlString: urlString))
    }

    var body: some View {
        Group {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder(loader.isLoading)
            }
        }
        .onAppear {
            loader.load(urlString: urlString)
        }
        .onChange(of: urlString) { newValue in
            loader.load(urlString: newValue)
        }
    }
}

@MainActor
private final class CachedRemoteImageLoader: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var isLoading = false

    private static let cache = URLCache(
        memoryCapacity: 50 * 1024 * 1024,
        diskCapacity: 200 * 1024 * 1024,
        diskPath: "character-image-cache"
    )

    private var currentURLString: String
    private var task: URLSessionDataTask?

    init(urlString: String) {
        self.currentURLString = urlString
    }

    deinit {
        task?.cancel()
    }

    func load(urlString: String) {
        guard currentURLString != urlString || image == nil else { return }

        currentURLString = urlString
        task?.cancel()
        image = nil

        guard let url = URL(string: urlString), !urlString.isEmpty else {
            isLoading = false
            return
        }

        let request = URLRequest(url: url)
        if let cachedResponse = Self.cache.cachedResponse(for: request),
           let cachedImage = UIImage(data: cachedResponse.data) {
            image = cachedImage
            isLoading = false
            return
        }

        isLoading = true
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, _ in
            guard let self else { return }

            Task { @MainActor in
                defer {
                    self.isLoading = false
                    self.task = nil
                }

                guard self.currentURLString == urlString,
                      let data,
                      let loadedImage = UIImage(data: data) else {
                    return
                }

                if let response {
                    let cachedResponse = CachedURLResponse(response: response, data: data)
                    Self.cache.storeCachedResponse(cachedResponse, for: request)
                }

                self.image = loadedImage
            }
        }
        task?.resume()
    }
}

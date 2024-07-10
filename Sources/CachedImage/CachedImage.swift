//
//  CachedImage.swift
//  CachedImage
//
//  Created by Vadym Bulavin on 2/13/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import SwiftUI

public struct CachedImage<Placeholder: View, Content: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: Placeholder
    @StateObject private var loader: ImageLoader
    @Environment(\.imageCache) var imageCache

    public init(
        url: URL?,
        content: @escaping (Image) -> Content,
        placeholder: @escaping () -> Placeholder,
        preload: Bool = false
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder()
        _loader = StateObject(
            wrappedValue: ImageLoader()
        )
        if preload {
            load()
        }
    }
    
    private func load() {
        loader.setCache(cache: _imageCache.wrappedValue)
        if let url = url {
            loader.load(url: url)
        }
    }

    public var body: some View {
        contentOrImage
            .onAppear {
                load()
            }
            .onChange(of: url) { newUrl in
                if let url = newUrl {
                    loader.reload(url: url)
                }
            }
    }

    @ViewBuilder
    private var contentOrImage: some View {
        if let platformImage = loader.image {
            content(Image(platformImage: platformImage))
        } else {
            placeholder
        }
    }
}

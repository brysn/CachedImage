//
//  CachedImage.swift
//  CachedImage
//
//  Created by Vadym Bulavin on 2/13/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import SwiftUI

private let defaultCache = DefaultImageCache()

public struct CachedImage<Placeholder: View, Content: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    private let placeholder: Placeholder
    @StateObject private var loader: ImageLoader

    public init(
        url: URL?,
        cache: ImageCache? = nil,
        preload: Bool = false,
        content: @escaping (Image) -> Content,
        placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder()
        _loader = StateObject(
            wrappedValue: ImageLoader(cache: cache ?? defaultCache, url: preload ? url : nil)
        )
    }

    public var body: some View {
        contentOrImage
            .onAppear {
                if let url = url {
                    loader.load(url: url)
                }
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

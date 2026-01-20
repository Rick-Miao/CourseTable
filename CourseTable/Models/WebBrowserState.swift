//
//  WebBrowserState.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/20.
//

import Foundation
import Combine

@MainActor
class WebBrowserState: ObservableObject {
    @Published var showingWebImporter = false
    @Published var urlToLoad: String? = nil
    
    func openBrowser(with url: String) {
        print("WebBrowserState: 打开浏览器，URL: \(url)")
        urlToLoad = url
        showingWebImporter = true
    }
    
    func reset() {
        print("WebBrowserState: 重置状态")
        urlToLoad = nil
        showingWebImporter = false
    }
}

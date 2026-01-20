//
//  CustomWebBrowserView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/20.
//

import SwiftUI
import WebKit

struct CustomWebBrowserView: UIViewControllerRepresentable {
    let initialURL: String
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> CustomWebBrowserViewController {
        return CustomWebBrowserViewController(initialURL: initialURL, onDismiss: {[dismiss] in dismiss()})
    }
    
    func updateUIViewController(_ uiViewController: CustomWebBrowserViewController, context: Context) {}
}

class CustomWebBrowserViewController: UIViewController {
    private var webView: WKWebView!
    private var urlTextField: UITextField!
    private var progressView: UIProgressView!
    
    private let initialURL: String
    private let onDismiss: () -> Void
    
    init(initialURL: String, onDismiss: @escaping () -> Void) {
        self.initialURL = initialURL
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadInitialPage()
    }
    
    private func setupUI() {
        // 1. 网址栏容器
        let urlContainer = UIView()
        urlContainer.backgroundColor = .systemBackground
        urlContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(urlContainer)
        
        // 2. 关闭按钮
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .label
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        urlContainer.addSubview(closeButton)
        
        // 3. 网址输入框
        urlTextField = UITextField()
        urlTextField.borderStyle = .roundedRect
        urlTextField.font = .systemFont(ofSize: 14)
        urlTextField.clearButtonMode = .whileEditing
        urlTextField.delegate = self
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        urlContainer.addSubview(urlTextField)
        
        // 4. 进度条
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .systemBlue
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        // 5. WebView
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        // 布局约束
        NSLayoutConstraint.activate([
            // 网址容器
            urlContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            urlContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            urlContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            urlContainer.heightAnchor.constraint(equalToConstant: 50),
            
            // 关闭按钮
            closeButton.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: urlContainer.leadingAnchor, constant: 12),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            
            // 网址输入框
            urlTextField.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
            urlTextField.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 8),
            urlTextField.trailingAnchor.constraint(equalTo: urlContainer.trailingAnchor, constant: -12),
            urlTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 30),
            
            // 进度条
            progressView.topAnchor.constraint(equalTo: urlContainer.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3),
            
            // WebView
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadInitialPage() {
        print("准备加载 URL: \(initialURL)")
        guard !initialURL.isEmpty else {
            print("URL 为空")
            return
        }
        // 清理 URL
        var finalURL = initialURL.trimmingCharacters(in: .whitespaces)
        
        // 确保 URL 有协议前缀
        if !finalURL.hasPrefix("http://") && !finalURL.hasPrefix("https://") {
            finalURL = "https://" + finalURL
        }
        guard let url = URL(string: finalURL) else {
            print("无法解析 URL: '\(finalURL)'")
            return
        }
        
        urlTextField.text = finalURL
        print("开始加载 URL: \(finalURL)")
        
        let request = URLRequest(url: url, timeoutInterval: 30)
        webView.load(request)
    }
    
    @objc private func closeButtonTapped() {
        onDismiss()
    }
}

// MARK: - UITextFieldDelegate
extension CustomWebBrowserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text,
              let url = URL(string: text) else {
            return false
        }
        
        webView.load(URLRequest(url: url))
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - WKNavigationDelegate
extension CustomWebBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("开始加载页面...")
        progressView.setProgress(0.1, animated: true)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("开始接收内容...")
        progressView.setProgress(0.5, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("页面加载完成")
        progressView.setProgress(1.0, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.progressView.setProgress(0.0, animated: true)
        }
        
        if let url = webView.url?.absoluteString {
            urlTextField.text = url
            print("当前 URL: \(url)")
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("页面加载失败: \(error.localizedDescription)")
        progressView.setProgress(0.0, animated: true)
        
        // 显示错误信息
        let alert = UIAlertController(title: "加载失败", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "重试", style: .default, handler: { _ in
            self.loadInitialPage()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("加载失败: \(error.localizedDescription)")
        progressView.setProgress(0.0, animated: true)
    }    
    
    // 监听加载进度
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            if let progress = webView.estimatedProgress as? Float {
                progressView.setProgress(progress, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}

// MARK: - WKUIDelegate
extension CustomWebBrowserViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // 处理新窗口打开（如 target="_blank"）
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

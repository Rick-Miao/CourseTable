//
//  HeaderView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI
import UniformTypeIdentifiers

struct HeaderView: View {
    let today: Date
    @Binding var currentDate: Date
    @Binding var currentWeek: Int
    let maxWeeks: Int
    let exportData: () -> Data?
    let importData: (Data, String) -> Void
    let showCourseList: () -> Void
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingImporter = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(today.formatDate())
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingImporter = true
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 18))
                        .padding(8)
                }
                .tint(.primary)
                .fileImporter(
                    isPresented: $showingImporter,
                    allowedContentTypes: [UTType.json],
                    onCompletion: handleImport)
                
                Button(action: {
                    export()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .padding(8)
                }
                .tint(.primary)
                
                Button(action: {
                    showCourseList()
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .padding(8)
                }
                .tint(.primary)
            }
            .padding(.horizontal)
        
            
            
            HStack {
                Text("第\(currentWeek)周")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                // 周数切换按钮（框架）
                HStack(spacing: 15) {
                    Button("上一周") {
                        if currentWeek > 1 {
                            currentWeek -= 1
                            if let newDate = Calendar.current.date(byAdding: .day, value: -7, to: currentDate) {
                                currentDate = newDate
                            }
                        }
                    }
                    
                    Button("下一周") {
                        if currentWeek < maxWeeks {
                            currentWeek += 1
                            if let newDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate) {
                                currentDate = newDate
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .alert(alertMessage, isPresented: $showingAlert) { }
    }
    
    private func export() {
        guard let data = exportData() else {
            showAlert("无法生成课程表数据")
            return
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        let fileName = "CourseTable_\(formatter.string(from: Date())).json"
        let fileURL = FileManager.default.temporaryDirectory.appending(path: fileName)
        
        do {
            try data.write(to: fileURL)
            
            // 调用 UIKit 分享
            DispatchQueue.main.async {
                guard let rootVC = UIApplication.shared.windows.first?.rootViewController else { return }
                let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            showAlert("导出失败: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    private func handleImport(result: Result<URL, Error>) {
          switch result {
          case .success(let fileURL):
              let isAccessGranted = fileURL.startAccessingSecurityScopedResource()
              
              defer {
                  if isAccessGranted {
                      fileURL.stopAccessingSecurityScopedResource()  // 👈 释放权限
                  }
              }
              
              do {
                  let data = try Data(contentsOf: fileURL)

                  let originalName = fileURL.deletingPathExtension().lastPathComponent
                  importData(data, originalName)
              } catch {
                  showAlert("读取文件失败: \(error.localizedDescription)")
              }
          case .failure(let error):
              showAlert("导入取消或失败: \(error.localizedDescription)")
          }
      }
}

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
    @Binding var showingImportOptions: Bool
    @Binding var importButtonRect: CGRect
    let maxWeeks: Int
    let exportData: () -> Data?
    let importData: (Data, String) -> Void
    let showCourseList: () -> Void
    let onShowAlert: (String) -> Void
    let config: Config?
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(today.formatDate())
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingImportOptions = true
                }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 18))
                        .padding(8)
                }
                .tint(.primary)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                importButtonRect = geometry.frame(in: .global)
                            }
                            .onChange(of: geometry.frame(in: .global)) { _, newRect in
                                importButtonRect = newRect
                            }
                    }
                )
                
                
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
                Text(weekStatusText)
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
    }
    
    private var weekStatusText: String {
        guard let config = config else {
            return "第\(currentWeek)周"
        }
        
        let formatter = DateFormatter.yyyyMMdd
        guard let semesterStart = formatter.date(from: config.semesterStart) else {
            return "第\(currentWeek)周"
        }
        
        let today = Date()
        let calendar = Calendar.current
        
        // 计算学期第一天（周一）
        let semesterFirstDay = semesterStart
        
        // 计算学期最后一天
        let semesterLastDay = calendar.date(byAdding: .day, value: (config.totalWeeks * 7) - 1, to: semesterFirstDay) ?? semesterFirstDay
        
        if today < semesterFirstDay {
            return "第\(currentWeek)周（学期未开始）"
        } else if today > semesterLastDay {
            return "第\(currentWeek)周（学期已结束）"
        } else {
            return "第\(currentWeek)周"
        }
    }
    
    private func export() {
        guard let data = exportData() else {
            // 需要通过回调处理 alert
            onShowAlert("无法生成课程表数据")
            return
        }
        let fileName = "CourseTable_\(DateFormatter.exportFileName.string(from: Date())).json"
        let fileURL = FileManager.default.temporaryDirectory.appending(path: fileName)
        
        do {
            try data.write(to: fileURL)
            
            // 调用 UIKit 分享
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
                    rootVC.present(activityVC, animated: true)
                }
            }
        } catch {
            showAlert("导出失败: \(error.localizedDescription)")
        }
    }
    
    private func showAlert(_ message: String) {
        onShowAlert(message)
    }
}

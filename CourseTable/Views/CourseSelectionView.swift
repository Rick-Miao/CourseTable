//
//  CourseSelectionView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/19.
//

import SwiftUI

struct CourseSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var courseNames: [String]
    let onSelect: (String) -> Void
    let onRename: (String, String) -> Void
    let onDelete: (String) -> Void

    @State private var showingRenameAlert = false
    @State private var currentName = ""
    @State private var newName = ""
    
    var body: some View {
        NavigationStack {
            List(courseNames, id: \.self) { fullName in
                let displayName = extractDisplayName(fullName)
                Button(action: {
                    onSelect(fullName)
                    dismiss()
                }) {
                    HStack {
                        Text(displayName)
                        Spacer()
                    }
                    .contentShape(Rectangle()) // 👈 确保整行可点击
                }
                .buttonStyle(.plain) // 👈 去除默认按钮样式
                
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        onDelete(fullName)
                    } label: {
                        Image(systemName: "trash")
                    }
                    
                    Button {
                        startRename(fullName)
                    } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
            .navigationTitle("课程表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            // 重命名弹窗
            .alert("重命名课程表", isPresented: $showingRenameAlert) {
                TextField("新名称", text: $newName)
                Button("取消", role: .cancel) { }
                Button("确定") {
                    onRename(currentName, newName)
                }
            } message: {
                Text("请输入新名称")
            }
        }
    }
    
    private func extractDisplayName(_ fullName: String) -> String {
        if let underscoreIndex = fullName.firstIndex(of: "_") {
            return String(fullName[fullName.index(after: underscoreIndex)...])
        }
        return fullName
    }
    
    private func startRename(_ name: String) {
        currentName = name
        newName = name
        showingRenameAlert = true
    }
}

// 右滑操作组件
struct SwipeActions: View {
    let name: String
    let onRename: (String) -> Void
    let onDelete: (String) -> Void
    
    var body: some View {
        HStack {
            Text(name)
            Spacer()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete(name)
            } label: {
                Image(systemName: "trash")
                    .background(Color(.red))
            }
            
            Button {
                onRename(name)
            } label: {
                Image(systemName: "pencil")
            }
        }
    }
}

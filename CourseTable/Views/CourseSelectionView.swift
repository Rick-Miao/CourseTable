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
            List(courseNames, id: \.self) { name in
                // 右滑操作
                SwipeActions(name: name, onRename: startRename, onDelete: onDelete)
                    .onTapGesture {
                        onSelect(name)
                        dismiss()
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

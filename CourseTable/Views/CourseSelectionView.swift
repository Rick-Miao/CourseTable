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
    let onEdit: (String) -> Void
    let onDelete: (String) -> Void
    
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
                        onEdit(fullName)
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
        }
    }
    
    private func extractDisplayName(_ fullName: String) -> String {
        if let underscoreIndex = fullName.firstIndex(of: "_") {
            return String(fullName[fullName.index(after: underscoreIndex)...])
        }
        return fullName
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

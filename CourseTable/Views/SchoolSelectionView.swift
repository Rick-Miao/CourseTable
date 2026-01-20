//
//  SchoolSelectionView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/20.
//

import SwiftUI

struct SchoolSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    let schools: [School]
    let onSelect: (School) -> Void
    
    var body: some View {
        NavigationStack {
            List(schools) { school in
                Button(action: {
                    onSelect(school)
                    dismiss()
                }) {
                    HStack {
                        Text(school.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("选择学校")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

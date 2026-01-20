//
//  ImportOptionsView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/20.
//

import SwiftUI

struct ImportOptionsView: View {
    let onDismiss: () -> Void
    let onSchoolImport: () -> Void
    let onJsonImport: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button("学校教务导入") {
                onSchoolImport()
            }
            .font(.system(size: 16))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .foregroundColor(.primary)
            
            Divider()
            
            Button("JSON 导入") {
                onJsonImport()
            }
            .font(.system(size: 16))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .foregroundColor(.primary)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .clipped()
    }
}

//
//  HeaderView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

struct HeaderView: View {
    @Binding var currentDate: Date
    @Binding var currentWeek: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(currentDate.formatDate())
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            HStack {
                Text("第\(currentWeek)周")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                // 周数切换按钮（框架）
                HStack(spacing: 15) {
                    Button("上一周") {
                        // TODO: 切换周数逻辑
                        if currentWeek > 1 {
                            currentWeek -= 1
                        }
                    }
                    
                    Button("下一周") {
                        // TODO: 切换周数逻辑
                        currentWeek += 1
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
    }
}

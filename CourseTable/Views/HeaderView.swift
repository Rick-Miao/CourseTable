//
//  HeaderView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

struct HeaderView: View {
    let today: Date
    @Binding var currentDate: Date
    @Binding var currentWeek: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(today.formatDate())
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            HStack {
                Text("第\(currentWeek)周")
                    .font(.system(size: 16, weight: .medium))
                
                Spacer()
                
                // 周数切换按钮（框架）
                HStack(spacing: 15) {
                    Button("上一周") {
                        if currentWeek > 1 {
                            currentWeek -= 1
                            // 👇 关键：currentDate 向前移 7 天
                            if let newDate = Calendar.current.date(byAdding: .day, value: -7, to: currentDate) {
                                currentDate = newDate
                            }
                        }
                    }
                    
                    Button("下一周") {
                        if currentWeek < 20 {
                            currentWeek += 1
                            // 👇 关键：currentDate 向后移 7 天
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
}

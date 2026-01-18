//
//  WeekHeaderView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

struct WeekHeaderView: View {
    let currentDate: Date
    
    var body: some View {
        HStack(spacing: 0) {
            // 左侧空白单元格
            Text("")
                .frame(width: 60, height: 50)
            
            // 星期表头（周一至周日）
            ForEach(0..<7, id: \.self) { index in
                Text(weekdayText(for: index))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color(.separator)),
                        alignment: .bottom
                    )
                    .overlay(
                        Rectangle()
                            .frame(width: 1)
                            .foregroundColor(Color(.separator)),
                        alignment: .trailing
                    )
            }
        }
        .frame(height: 50)
        .background(Color(.systemBackground))
    }
    
    private func weekdayText(for index: Int) -> String {
        let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
        return weekdays[index]
    }
}

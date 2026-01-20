//
//  WeekHeaderView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

struct WeekHeaderView: View {
    let currentDate: Date
    
    private var weekdayDates: [Int] {
        let calendar = Calendar.current
        return (0..<7).map { offset in
            if let date = calendar.date(byAdding: .day, value: offset, to: currentDate) {
                return calendar.component(.day, from: date)
            } else {
                return -1
            }
        }
    }
    
    private var monthString: String {
        return DateFormatter.monthNumber.string(from: currentDate)
    }
    
    var body: some View {
        VStack(spacing: 0){
            HStack(spacing: 0) {
                // 左侧空白单元格
                Text(monthString)
//                    .font(.system(size: 12, weight: .medium))
                    .frame(width: 60, height: 24)
                    .background(Color(.systemBackground))
                
                // 星期表头（周一至周日）
                ForEach(0..<7, id: \.self) { index in
                    Text(weekdayText(for: index))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color(.systemBackground))
                }
            }
            .frame(height: 30)
            
            // 第二行：日期数字（只周一到周五）
            HStack(spacing: 0) {
                Text("月")
                    .frame(width: 60, height: 30)
                
                ForEach(0..<7, id: \.self) { index in
                    Text("\(weekdayDates[index])")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 2)
                        .background(Color(.systemBackground))
                }
            }
            .frame(height: 30)
        }
        .background(Color(.systemBackground))
    }
    
    private func weekdayText(for index: Int) -> String {
        let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
        return weekdays[index]
    }
}

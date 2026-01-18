//
//  CourseGridView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

struct CourseGridView: View {
    let courses: [Course]
    let times: [(period: String, startTime: String, endTime: String)]
    let currentWeek: Int
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<times.count, id: \.self) { timeIndex in
                HStack(spacing: 0) {
                    // 左侧时间列
                    TimeColumnView(timeIndex: timeIndex,times: times)
                    
                    // 课程单元格（周一至周日）
                    ForEach(0..<7, id: \.self) { dayIndex in
                        let day = dayIndex + 1
                        let time = timeIndex + 1
                        
                        EmptyCellView()
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 80)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.separator)),
                    alignment: .bottom
                )
            }
        }
        .background(Color(.systemBackground))
    }
}

struct TimeColumnView: View {
    let timeIndex: Int
    let times: [(period: String, startTime: String, endTime: String)]
    
    var body: some View {
        VStack(spacing: 4) {
            Text(times[timeIndex].period)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Text(times[timeIndex].startTime)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            
            Text(times[timeIndex].endTime)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .frame(width: 60)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(width: 1)
                .foregroundColor(Color(.separator)),
            alignment: .trailing
        )
    }
}

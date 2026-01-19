//
//  CourseDetailView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/19.
//

import SwiftUI

struct CourseDetailView: View {
    let course: Course
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("课程信息") {
                    Text(course.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("教师：\(course.teacher)")
                    Text("教室：\(course.classroom)")
                    Text("星期：周\(weekdayString(course.week))")
                    Text("节次：\(formatTimes(course.times))")
                    Text("周数：第 \(course.startWeek)–\(course.endWeek) 周")
                }
            }
            .navigationTitle("课程详情")
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
    
    private func weekdayString(_ week: Int) -> String {
        let weekdays = ["", "一", "二", "三", "四", "五", "六", "日"]
        return weekdays[week]
    }
    
    private func formatTimes(_ times: [Int]) -> String {
        let sorted = times.sorted()
        if sorted.count == 1 {
            return "第 \(sorted[0]) 节"
        } else {
            return "第 \(sorted.first!)–\(sorted.last!) 节"
        }
    }
}

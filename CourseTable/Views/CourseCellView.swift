//
//  CourseCellView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

struct CourseCellView: View {
    let day: Int
    let time: Int
    let courses: [Course]
    let currentWeek: Int
    
    var body: some View {
        // TODO: 根据课程数据找到对应课程
        // 这里先实现占位逻辑
        
        let course = findCourse(for: day, at: time)
        
        if let course = course {
            CourseCell(course: course)
        } else {
            EmptyCellView()
        }
    }
    
    private func findCourse(for day: Int, at time: Int) -> Course? {
        // TODO: 实现课程查找逻辑
        // 检查星期和节次，并考虑单双周
        return nil
    }
}

struct CourseCell: View {
    let course: Course
    
    var body: some View {
        VStack(spacing: 2) {
            Text(course.name)
                .font(.system(size: 12, weight: .medium))
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text(course.classroom)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(4)
        .padding(2)
    }
}

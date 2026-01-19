//
//  CourseCellView.swift
//  CourseTable
//  弃用
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

struct CourseCellView: View {
    let day: Int
    let time: Int
    let courses: [Course]
    let currentWeek: Int
    
    var body: some View {
        let course = findCourse(for: day, at: time)
        
        if let course = course {
            CourseCell(course: course)
        } else {
            EmptyCellView()
        }
    }
    
    private func findCourse(for day: Int, at time: Int) -> Course? {
        for course in courses {
            if course.week == day &&
                course.times.contains(time) &&
                currentWeek >= course.startWeek &&
                currentWeek <= course.endWeek {
                    return course
            }
        }
        return nil
    }
}

struct CourseCell: View {
    let course: Course
    
    var body: some View {
        Text("\(course.name) @ \(course.classroom)")
              .font(.system(size: 12, weight: .medium))
              .lineLimit(2)
              .multilineTextAlignment(.center)
              .padding(.horizontal, 4)
              .padding(.vertical, 6)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
              .cornerRadius(4)
              .padding(2)
    }
}

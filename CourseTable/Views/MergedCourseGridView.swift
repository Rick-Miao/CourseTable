//
//  MergedCourseGridView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/19.
//

import SwiftUI

struct MergedCourseGridView: View {
    let courses: [Course]
    let currentWeek: Int
    let times: [(period: String, startTime: String, endTime: String)]
    @State private var selectedCourse: Course? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<times.count, id: \.self) { timeIndex in
                HStack(spacing: 0) {
                    // 左侧：时间列（固定宽度）
                    TimeColumnView(timeIndex: timeIndex, times: times)
                        .frame(width: 60, height: 80)
                    
                    // 右侧：7天的课程
                    ForEach(0..<7, id: \.self) { dayIndex in
                        let day = dayIndex + 1
                        let time = timeIndex + 1
                        
                        // 查找当天当前节是否有起始课程
                        if let (course, span) = findStartingCourse(for: day, at: time) {
                            // 是起始节：显示合并单元格
                            MergedCourseCell(course: course)
                                .frame(height: CGFloat(span) * 80 - 1)
                                .offset(y: CGFloat(span - 1) * 40)
                                .onTapGesture {
                                    selectedCourse = course
                                }
                        } else if isPartOfCourse(for: day, at: time) {
                            Color.clear
                        } else {
                            EmptyCellView()
                        }
                    }
                }
                .frame(height: 80)
            }
        }
        .background(Color(.systemBackground))
        .sheet(item: $selectedCourse) { course in
            CourseDetailView(course: course)
        }
    }
    
    private func findStartingCourse(for day: Int, at time: Int) -> (Course, span: Int)? {
        for course in courses {
            guard course.week == day,
                  currentWeek >= course.startWeek,
                  currentWeek <= course.endWeek,
                  course.times.contains(time) else { continue }
            
            let sortedTimes = course.times.sorted()
            if sortedTimes.first == time {
                return (course, sortedTimes.count)
            }
        }
        return nil
    }
    
    private func isPartOfCourse(for day: Int, at time: Int) -> Bool {
        // 检查该节是否属于某个课程的非起始部分
        for course in courses {
            guard course.week == day,
                  currentWeek >= course.startWeek,
                  currentWeek <= course.endWeek,
                  course.times.contains(time) else { continue }
            
            let sortedTimes = course.times.sorted()
            return sortedTimes.first != time // 不是第一节就是中间节
        }
        return false
    }
    
    private struct MergedCourseCell: View {
        let course: Course
        
        var body: some View {
            Text("\(course.name) @ \(course.classroom)")
                .font(.system(size: 12, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(4)
                .padding(2)
        }
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
    }
}

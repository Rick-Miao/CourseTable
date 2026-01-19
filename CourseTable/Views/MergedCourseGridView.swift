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
        LazyVStack(spacing: 0) {
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
//        guard let course = gridData.first(where: { $0.day == day })?
//                .cells.enumerated().first(where: {
//                    if case .course(let c, let span) = $0.element {
//                        let startIndex = $0.offset
//                        let actualTime = startIndex + 1
//                        return actualTime == time
//                    }
//                    return false
//                }) else { return nil }
//        
//        if case .course(let c, let span) = course.element {
//            return (c, span)
//        }
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
//        guard let dayColumn = gridData.first(where: { $0.day == day }) else { return false }
//        
//        for (index, cell) in dayColumn.cells.enumerated() {
//            let cellTime = index + 1
//            if case .course(_, let span) = cell {
//                if time > cellTime && time < cellTime + span {
//                    return true
//                }
//            }
//        }
        return false
    }
    
    private func calculateRowHeight(rowIndex: Int) -> Double {
        // 找到该行对应的所有 span，取最大值
        // 简化处理：直接返回 80（因为时间列不需要合并）
        return 80
    }
    
    private struct MergedCourseCell: View {
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
            .background(Color.blue.opacity(0.15))
            .cornerRadius(4)
            .padding(2)
        }
    }
}



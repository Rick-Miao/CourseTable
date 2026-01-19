//
//  ContentView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

struct ContentView: View {
    @State private var courses: [Course] = []
    @State private var currentDate = Date()
    @State private var currentWeek = 1
        
    // 时间表配置
    private let times: [(period: String, startTime: String, endTime: String)] = [
            ("1", "08:30", "09:15"),
            ("2", "09:20", "10:05"),
            ("3", "10:25", "11:10"),
            ("4", "11:15", "12:00"),
            ("5", "13:30", "14:15"),
            ("6", "14:20", "15:05"),
            ("7", "15:25", "16:10"),
            ("8", "16:15", "17:00"),
            ("9", "17:05", "17:50"),
            ("10", "18:30", "19:15"),
            ("11", "19:20", "20:05"),
            ("12", "20:10", "20:55")
        ]
    
    @State private var gridData: [DayColumn] = []
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HeaderView(currentDate: $currentDate, currentWeek: $currentWeek)
            
            // 主体内容
            MainContentView()
        }
        .onAppear(perform: loadData)
        .onChange(of: currentWeek) { _, _ in
            gridData = buildGridData()
        }
    }
    
    private func MainContentView() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // 星期表头
                WeekHeaderView(currentDate: currentDate)
                
                // 课程表格
                // CourseGridView(courses: courses,times: times, currentWeek: currentWeek)
                MergedCourseGridView(courses: courses, currentWeek: currentWeek, times: times)
            }
        }
    }
    
    private func loadData() {
        //TODO: 这里实现数据加载逻辑
        loadCourses()
        calculateCurrentWeek()
        let mergedCourses = mergeConsecutiveCourses(courses)
        self.courses = mergedCourses
        gridData = buildGridData()
    }
    
    private func loadCourses() {
        guard let url = Bundle.main.url(forResource:"courses", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
                  print("无法加载courses.json")
                  return
              }
        
        struct Wrapper: Codable {
            let courses: [Course]
        }
        
        if let wrapper = try? JSONDecoder().decode(Wrapper.self, from: data) {
            self.courses = wrapper.courses
        } else {
            print("解码courses.json失败")
        }
    }
   
    private func calculateCurrentWeek() {
        // TODO: 计算当前是第几周
        // 这里暂时设置为第1周
        self.currentWeek = 1
    }

    private func buildGridData() -> [DayColumn] {
        var columns = (1...7).map { DayColumn(day: $0) }
        for day in 1...7 {
            var dayCourses = courses.filter {
                $0.week == day &&
                currentWeek >= $0.startWeek &&
                currentWeek <= $0.endWeek
            }
                .sorted { $0.times.first! < $1.times.first! }
            
            var usedTimes = Set<Int>()
            var cells: [CellItem] = []
            
            for time in 1...12 {
                if usedTimes.contains(time) {
                    continue
                }
                if let course = dayCourses.first(where: { $0.times.contains(time) }) {
                    // 找到连续节次范围
                    let sortedTimes = course.times.sorted()
                    guard let startIndex = sortedTimes.firstIndex(of: time) else { continue }
                    
                    var span = 1
                    while startIndex + span < sortedTimes.count,
                          sortedTimes[startIndex + span] == time + span {
                        span += 1
                    }
                    
                    // 标记这些节次已使用
                    for t in time..<(time + span) {
                        usedTimes.insert(t)
                    }
                    
                    cells.append(.course(course, span: span))
                } else {
                    cells.append(.empty)
                }
            }
            columns[day - 1].cells = cells
        }
        return columns
    }
    private func mergeConsecutiveCourses(_ courses: [Course]) -> [Course] {
        // 按 day + name + teacher + classroom 分组
        let grouped = Dictionary(grouping: courses) { course in
            "\(course.week)-\(course.name)-\(course.teacher)-\(course.classroom)-\(course.startWeek)-\(course.endWeek)"
        }
        
        var merged: [Course] = []
        
        for group in grouped.values {
            // 合并所有 times
            var allTimes = Set<Int>()
            for course in group {
                allTimes.formUnion(course.times)
            }
            
            // 排序并合并连续节次（其实 Set 已去重，直接排序即可）
            let sortedTimes = Array(allTimes).sorted()
            
            // 创建新 Course（取第一个作为模板）
            let template = group[0]
            let mergedCourse = Course(
                name: template.name,
                teacher: template.teacher,
                classroom: template.classroom,
                week: template.week,
                times: sortedTimes,
                startWeek: template.startWeek,
                endWeek: template.endWeek
            )
            
            merged.append(mergedCourse)
        }
        
        return merged
    }
}


    


#Preview {
    ContentView()
}

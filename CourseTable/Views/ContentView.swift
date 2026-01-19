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
    @State private var config: Config? = nil
    private var times: [(period: String, startTime: String, endTime: String)] {
        guard let config = config else {
            return [
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
        }
        return config.periods.map { (period: $0.period, startTime: $0.startTime, endTime: $0.endTime) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HeaderView(
                today: Date(),
                currentDate: $currentDate,
                currentWeek: $currentWeek,
                maxWeeks: config?.totalWeeks ?? 20,
                exportData: {
                    struct ExportWrapper: Codable {
                        let config: Config
                        let courses: [Course]
                    }
                    
                    guard let config = self.config else { return nil }
                    let wrapper = ExportWrapper(config: config, courses: self.courses)
                    
                    do {
                        let data = try JSONEncoder().encode(wrapper)
                        return data
                    } catch {
                        print("导出编码失败: \(error)")
                        return nil
                    }
                },
                importData: { data in
                    self.saveImportedData(data)
                    self.decodeAndSetData(data)
                    self.calculateCurrentWeek()
                }
            )
            
            // 主体内容
            MainContentView()
        }
        .onAppear(perform: loadData)
    }
    
    private func MainContentView() -> some View {
        VStack(spacing: 0) {
            // 固定表头（不滚动）
            WeekHeaderView(currentDate: currentDate)
            
            // 可滚动的课程内容
            ScrollView(.vertical, showsIndicators: false) {
                MergedCourseGridView(courses: courses, currentWeek: currentWeek, times: times)
            }
        }
    }
    
    private func loadData() {
        loadCourses()
        calculateCurrentWeek()
        let mergedCourses = mergeConsecutiveCourses(courses)
        self.courses = mergedCourses
    }
    
    private func loadCourses() {
        // 优先从 courseData 目录加载
        if FileManager.default.fileExists(atPath: currentCourseFileURL.path) {
            if let data = try? Data(contentsOf: currentCourseFileURL) {
                decodeAndSetData(data)
                return
            }
        }
        
        // 首次启动：courses 保持为空
        self.courses = []
        self.config = nil
    }

    private func decodeAndSetData(_ data: Data) {
        struct Wrapper: Codable {
            let config: Config
            let courses: [Course]
        }
        
        do {
            let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
            self.config = wrapper.config
            self.courses = wrapper.courses
        } catch {
            print("解码失败: \(error)")
            // 加载失败时清空数据
            self.courses = []
            self.config = nil
        }
    }
   
    private func calculateCurrentWeek() {
        // 使用 ISO 周（周一为每周第一天）
        var isoCalendar = Calendar.current
        isoCalendar.firstWeekday = 2
        isoCalendar.minimumDaysInFirstWeek = 4
        
        guard let config = self.config else {
            currentWeek = 1
            if let monday = isoCalendar.date(from: isoCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) {
                currentDate = monday
            }
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh_CN")

        guard let semesterStart = formatter.date(from: config.semesterStart) else {
            print("无法解析 config 中的 semesterStart: \(config.semesterStart)")
            currentWeek = 1
            return
        }

        let today = Date()
        let components = isoCalendar.dateComponents([.weekOfYear], from: semesterStart, to: today)
        let weeksElapsed = (components.weekOfYear ?? -1) + 1

        if weeksElapsed < 1 {
            currentWeek = 1
            // currentDate 设为学期开始日所在周的周一（即 semesterStart 本身，假设它已是周一）
            if let firstMonday = isoCalendar.date(from: isoCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: semesterStart)) {
                currentDate = firstMonday
            } else {
                currentDate = semesterStart
            }
        } else if weeksElapsed > config.totalWeeks {
            // 已结课：跳转到最后一周
            currentWeek = config.totalWeeks
            // 👇 计算最后一周的周一
            if let lastMonday = isoCalendar.date(byAdding: .weekOfYear, value: config.totalWeeks - 1, to: semesterStart) {
                currentDate = lastMonday
            } else {
                currentDate = semesterStart // fallback
            }
        } else {
            // 学期中：显示当前周
            currentWeek = weeksElapsed
            if let thisMonday = isoCalendar.date(from: isoCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) {
                currentDate = thisMonday
            }
        }
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
    
    private func handleImportedData(_ data: Data) {
        struct Wrapper: Codable {
            let config: Config
            let courses: [Course]
        }
        
        do {
            let wrapper = try JSONDecoder().decode(Wrapper.self, from: data)
            
            // 更新状态
            DispatchQueue.main.async {
                self.config = wrapper.config
                self.courses = mergeConsecutiveCourses(wrapper.courses)
                self.calculateCurrentWeek()  // 重新计算周数和日期
            }
        } catch {
            print("导入解析失败: \(error)")
        }
    }
    
    private var courseDataDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("courseData", isDirectory: true)
    }

    private var currentCourseFileURL: URL {
        courseDataDirectory.appendingPathComponent("current_course.json")
    }

    private func ensureCourseDataDirectoryExists() {
        if !FileManager.default.fileExists(atPath: courseDataDirectory.path) {
            try? FileManager.default.createDirectory(at: courseDataDirectory, withIntermediateDirectories: true)
        }
    }

    private func saveImportedData(_ data: Data) {
        ensureCourseDataDirectoryExists()
        try? data.write(to: currentCourseFileURL)
    }
}


    


#Preview {
    ContentView()
}

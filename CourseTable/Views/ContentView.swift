//
//  ContentView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI
import UniformTypeIdentifiers
import WebKit

struct ContentView: View {
    @State private var courses: [Course] = []
    @State private var currentDate = Date()
    @State private var currentWeek = 1
    @State private var config: Config? = nil
    @State private var showingCourseList = false
    @State private var courseNames: [String] = []
    @State private var showingEditView = false
    @State private var editCourseName = ""
    @State private var showingImportOptions = false
    @State private var importButtonRect = CGRect()
    @State private var showingImporter = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSchoolSelection = false
    @State private var showingWebImporter = false
    @State private var webBrowserURL: String? = nil
    @StateObject private var webBrowserState = WebBrowserState()
    
    private let lastSelectedCourseKey = "LastSelectedCourseName"
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
    
    private let schools: [School] = [
        School(name: "百度", url: "https://www.baidu.com"),
        School(name: "金陵科技学院（江宁校区）", url: "https://jwxt.jit.edu.cn"),
        School(name: "金陵科技学院（幕府校区）", url: "https://jwxt.jit.edu.cn")
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 顶部标题栏
                HeaderView(
                    today: Date(),
                    currentDate: $currentDate,
                    currentWeek: $currentWeek,
                    showingImportOptions: $showingImportOptions,
                    importButtonRect: $importButtonRect,
                    maxWeeks: config?.totalWeeks ?? 20,
                    exportData: {
                        guard let config = self.config else { return nil }
                        let wrapper = ConfigWrapper(config: config, courses: self.courses)
                        
                        do {
                            let data = try JSONEncoder().encode(wrapper)
                            return data
                        } catch {
                            print("导出编码失败: \(error)")
                            return nil
                        }
                    },
                    importData: { data, name in
                        self.saveImportedData(data, name: name)
                        self.decodeAndSetData(data)
                        self.calculateCurrentWeek()
                        let mergedCourses = mergeConsecutiveCourses(self.courses)
                        self.courses = mergedCourses
                        self.courseNames = self.loadAllCourseNames()
                    },
                    showCourseList: {
                        courseNames = loadAllCourseNames()
                        showingCourseList = true
                    },
                    onShowAlert: { message in
                        alertMessage = message
                        showingAlert = true
                    },
                    config: config
                )
                .alert(alertMessage, isPresented: $showingAlert) { }
                
                // 主体内容
                MainContentView()
            }
            .onAppear {
                loadData()
                courseNames = loadAllCourseNames()
            }
            // 课程表选择弹窗
            .sheet(isPresented: $showingCourseList) {
                CourseSelectionView(
                    courseNames: $courseNames,
                    onSelect: { name in
                        loadCourseByName(name)
                        showingCourseList = false
                        UserDefaults.standard.set(name, forKey: lastSelectedCourseKey)
                    },
                    onEdit: { name in
                        editCourseName = name
                        showingCourseList = false
                        showingEditView = true
                    },
                    onDelete: { name in
                        deleteCourse(name)
                        courseNames = loadAllCourseNames()
                    
                        // 重新加载课表
                        if let firstName = courseNames.first {
                            loadCourseByName(firstName)
                        } else {
                            DispatchQueue.main.async {
                                self.courses = []
                                self.config = nil
                                self.calculateCurrentWeek()
                            }
                        }
                    }
                )
            }
            .navigationDestination(isPresented: $showingEditView) {
                if let config = self.config {
                    CourseEditView(originalName: editCourseName, config: config)
                }
            }
            .overlay {
                if showingImportOptions {
                    ZStack {
                        Color.black.opacity(0.01)
                            .onTapGesture {
                                showingImportOptions = false
                            }
                        
                        ImportOptionsView(
                            onDismiss: {
                                showingImportOptions = false
                            },
                            onSchoolImport: {
                                showingImportOptions = false
                                showingSchoolSelection = true
                            },
                            onJsonImport: {
                                showingImportOptions = false
                                showingImporter = true
                            }
                        )
                        .frame(width: 200, height: 90)
                        .offset(x: importButtonRect.midX - 200, y: importButtonRect.maxY - 380) // 导入方式偏移
                    }
                    .zIndex(1)
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [UTType.json],
                onCompletion: handleImport
            )
            .sheet(isPresented: $showingSchoolSelection) {
                SchoolSelectionView(schools: schools) { selectedSchool in
                    let cleanURL = selectedSchool.url.trimmingCharacters(in: .whitespaces)
                    
                    var finalURL = cleanURL
                    if !finalURL.hasPrefix("http://") && !finalURL.hasPrefix("https://") {
                        finalURL = "https://" + finalURL
                    }
                    // 验证 URL 是否有效
                    if let url = URL(string: finalURL), UIApplication.shared.canOpenURL(url) {
                        print("准备打开 URL: \(finalURL)")
                        webBrowserState.openBrowser(with: finalURL)
                    } else {
                        print("无效的 URL: \(finalURL)")
                        alertMessage = "无法打开此网址：\(finalURL)"
                        showingAlert = true
                    }
                }
            }
            .sheet(isPresented: $webBrowserState.showingWebImporter) {
                if let url = webBrowserState.urlToLoad {
                    CustomWebBrowserView(initialURL: url)
                        .onDisappear {
                            // 浏览器关闭后重置状态
                            webBrowserState.reset()
                        }
                } else {
                    Text("URL 为空")
                        .onAppear {
                            print("错误：浏览器已显示但 URL 为空")
                        }
                }
            }
        }
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
        // 1. 尝试加载最后选择的课表
        if let lastName = UserDefaults.standard.string(forKey: lastSelectedCourseKey) {
            let fileURL = FileHelper.courseDataDirectory.appendingPathComponent("\(lastName).json")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let data = try? Data(contentsOf: fileURL) {
                    decodeAndSetData(data)
                    return
                }
            }
        }
        
        // 2. 回退到第一个课表
        let names = loadAllCourseNames()
        if let firstName = names.first {
            loadCourseByName(firstName)
            // 保存为最后选择的课表
            UserDefaults.standard.set(firstName, forKey: lastSelectedCourseKey)
            return
        }
        
        // 3. 没有课表时清空
        self.courses = []
        self.config = nil
    }


    private func decodeAndSetData(_ data: Data) {
        do {
            let wrapper = try JSONDecoder().decode(ConfigWrapper.self, from: data)
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

        guard let semesterStart = DateFormatter.yyyyMMdd.date(from: config.semesterStart) else {
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
        do {
            let wrapper = try JSONDecoder().decode(ConfigWrapper.self, from: data)
            
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

    private func saveImportedData(_ data: Data, name: String) {
        FileHelper.ensureCourseDataDirectoryExists()
        let safeName = name.replacingOccurrences(of: "/", with: "_") // 避免非法字符
        let fileURL = FileHelper.courseDataDirectory.appendingPathComponent("\(safeName).json")
        try? data.write(to: fileURL)
    }
    
    private func loadAllCourseNames() -> [String] {
        FileHelper.ensureCourseDataDirectoryExists()
        do {
            let files = try FileManager.default.contentsOfDirectory(at: FileHelper.courseDataDirectory, includingPropertiesForKeys: nil)
            return files
                .filter { $0.pathExtension == "json" }
                .map { $0.deletingPathExtension().lastPathComponent }
                .sorted()
        } catch {
            print("读取课程表列表失败: \(error)")
            return []
        }
    }

    private func loadCourseByName(_ name: String) {
        let fileURL = FileHelper.courseDataDirectory.appendingPathComponent("\(name).json")
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        if let data = try? Data(contentsOf: fileURL) {
            decodeAndSetData(data)
            calculateCurrentWeek()
            let mergedCourses = mergeConsecutiveCourses(courses)
            self.courses = mergedCourses
        }
    }
    
    private func renameCourse(_ oldName: String, to newName: String) {
        let oldURL = FileHelper.courseDataDirectory.appendingPathComponent("\(oldName).json")
        let newURL = FileHelper.courseDataDirectory.appendingPathComponent("\(newName).json")
        
        if FileManager.default.fileExists(atPath: oldURL.path) {
            try? FileManager.default.moveItem(at: oldURL, to: newURL)
        }
    }

    private func deleteCourse(_ name: String) {
        let fileURL = FileHelper.courseDataDirectory.appendingPathComponent("\(name).json")
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
    
    private func handleImport(result: Result<URL, Error>) {
          switch result {
          case .success(let fileURL):
              let isAccessGranted = fileURL.startAccessingSecurityScopedResource()
              
              defer {
                  if isAccessGranted {
                      fileURL.stopAccessingSecurityScopedResource()  // 释放权限
                  }
              }
              
              do {
                  let data = try Data(contentsOf: fileURL)
                  let originalName = fileURL.deletingPathExtension().lastPathComponent
                  saveImportedData(data, name: originalName)
                  decodeAndSetData(data)
                  calculateCurrentWeek()
                  let mergedCourses = mergeConsecutiveCourses(courses)
                  self.courses = mergedCourses
                  self.courseNames = loadAllCourseNames()
              } catch {
                  alertMessage = "读取文件失败: \(error.localizedDescription)"
                  showingAlert = true
              }
          case .failure(let error):
              alertMessage = "导入取消或失败: \(error.localizedDescription)"
              showingAlert = true
          }
      }
}

#Preview {
    ContentView()
}

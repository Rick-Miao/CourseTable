//
//  CourseEditView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/20.
//

import SwiftUI

struct CourseEditView: View {
    @Environment(\.dismiss) private var dismiss
    let originalName: String
    @State private var courseName: String
    @State private var semesterStart: Date
    @State private var totalWeeks: Int
    @State private var periods: [Config.Period]
    @State private var hasInitialized = false
       
    private let initialSemesterStart: Date
    private let initialTotalWeeks: Int
    private let initialPeriods: [Config.Period]
    
    
    init(originalName: String, config: Config) {
        self.originalName = originalName
        self.courseName = originalName
        
        // 解析初始日期
        self.initialSemesterStart = DateFormatter.yyyyMMdd.date(from: config.semesterStart) ?? Date()
        self.initialTotalWeeks = config.totalWeeks
        self.initialPeriods = config.periods
        
        self._semesterStart = State(initialValue: Date())
        self._totalWeeks = State(initialValue: 1)
        self._periods = State(initialValue: [])
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("课程表信息") {
                    TextField("课程表名称", text: $courseName)
                }
                
                Section("学期设置") {
                    DatePicker("学期开始日", selection: $semesterStart, displayedComponents: .date)
                    
                    Stepper("学期周数: \(totalWeeks)", value: $totalWeeks, in: 1...52)
                }
                
                NavigationLink("上课时间", destination: PeriodEditView(periods: $periods))
            }
            .navigationTitle("编辑课程表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("保存") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
            .onAppear {
                if !hasInitialized {
                    semesterStart = initialSemesterStart
                    totalWeeks = initialTotalWeeks
                    periods = initialPeriods
                    hasInitialized = true
                }
            }
        }
    }
    
    private func saveChanges() {
        // 1. 重命名文件
        if courseName != originalName {
            let oldURL = FileHelper.courseDataDirectory.appendingPathComponent("\(courseName).json")
            
            let newURL = oldURL.deletingLastPathComponent()
                .appendingPathComponent("\(courseName).json")
            
            try? FileManager.default.moveItem(at: oldURL, to: newURL)
        
            UserDefaults.standard.set(courseName, forKey: "LastSelectedCourseName")
        }
        
        // 2. 更新 JSON 中的 config
        updateConfigInFile()
    }
    
    private func updateConfigInFile() {
        let fileURL = FileHelper.courseDataDirectory.appendingPathComponent("\(courseName).json")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileURL)
            var wrapper = try JSONDecoder().decode(ConfigWrapper.self, from: data)
            
            // 更新配置
            wrapper.config.semesterStart = DateFormatter.yyyyMMdd.string(from: semesterStart)
            wrapper.config.totalWeeks = totalWeeks
            wrapper.config.periods = periods
            
            // 保存回文件
            let updatedData = try JSONEncoder().encode(wrapper)
            try updatedData.write(to: fileURL)
        } catch {
            print("更新配置失败: \(error)")
        }
    }
}

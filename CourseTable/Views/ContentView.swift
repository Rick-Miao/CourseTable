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
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标题栏
            HeaderView(currentDate: $currentDate, currentWeek: $currentWeek)
            
            // 主体内容
            MainContentView()
        }
        .onAppear(perform: loadData)
    }
    
    private func MainContentView() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // 星期表头
                WeekHeaderView(currentDate: currentDate)
                
                // 课程表格
                CourseGridView(courses: courses,times: times, currentWeek: currentWeek)
            }
        }
    }
    
    private func loadData() {
        //TODO: 这里实现数据加载逻辑
        loadCourses()
        calculateCurrentWeek()
    }
    
    private func loadCourses() {
        // TODO: 从JSON文件加载课程数据
        // 这里暂时返回空数组
        self.courses = []
    }
   
    private func calculateCurrentWeek() {
        // TODO: 计算当前是第几周
        // 这里暂时设置为第1周
        self.currentWeek = 1
    }
}

#Preview {
    ContentView()
}

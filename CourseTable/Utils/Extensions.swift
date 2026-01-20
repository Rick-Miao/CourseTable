//
//  Extensions.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

extension Date {
    func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: self)
    }
    
    func chineseWeekday() -> String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: self)
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]
        return weekdays[weekday - 1]
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    static let HHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    static let monthNumber: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()
    
    static let exportFileName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmm"
        return formatter
    }()
}

//
//  JITScheduleParser.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/20.
//

import Foundation
import SwiftSoup

struct ParsedCourse: Hashable {
    let name: String
    let teacher: String
    let classroom: String
    let week: Int
    let times: [Int]
    let startWeek: Int
    let endWeek: Int
}

enum ScheduleParseError: Error {
    case tableNotFound
    case invalidHTML
}

class JITScheduleParser {
    static func parse(html: String) throws -> ([ParsedCourse], Int) {
        guard let doc = try? SwiftSoup.parse(html) else {
            throw ScheduleParseError.invalidHTML
        }
        
        // 查找 Table1
        guard let table = try? doc.getElementById("Table1") else {
            throw ScheduleParseError.tableNotFound
        }
        
        let rows = try table.select("tr")
        guard rows.count > 1 else { throw ScheduleParseError.tableNotFound }
        
        var courses: [ParsedCourse] = []
        var maxPeriod = 12
        
        // 星期映射
        let weekdayMap: [String: Int] = [
            "周一": 1, "周二": 2, "周三": 3, "周四": 4,
            "周五": 5, "周六": 6, "周日": 7
        ]
        
        // 跳过表头（第0行）
        for rowIndex in 1..<rows.count {
            let row = rows[rowIndex]
            let cells = try row.select("td,th")
            
            // 需要至少9列（时间类型 + 节次 + 7天）
            guard cells.count >= 9 else { continue }
            
            // 获取节次信息（第1列）
            let periodText = try cells[1].text().trimmingCharacters(in: .whitespaces)
            guard periodText.range(of: #"第(\d+)节"#, options: .regularExpression) != nil else {
                continue
            }
            
            // 遍历每天（列2-8）
            for dayIndex in 2..<min(9, cells.count) {
                let cell = cells[dayIndex]
                let text = try cell.text().trimmingCharacters(in: .whitespaces)
                
                guard !text.isEmpty && text != " " else { continue }
                
                // 按换行分割内容
                let lines = text.components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                
                guard lines.count >= 4 else { continue }
                
                // 处理多课程
                var i = 0
                while i < lines.count {
                    if i + 3 < lines.count,
                       let timeInfo = lines[safe: i + 1],
                       timeInfo.range(of: #"\{第\d+-\d+周\}"#, options: .regularExpression) != nil {
                        
                        let courseName = lines[i]
                        let teacherLine = lines[i + 2]
                        let classroom = lines[i + 3]
                        
                        // 提取教师姓名（去除括号部分）
                        let teacher = teacherLine.components(separatedBy: "(").first?.trimmingCharacters(in: .whitespaces) ?? teacherLine
                        
                        // 验证时间格式
                        if let timeMatch = timeInfo.range(of: #"^(周一|周二|周三|周四|周五|周六|周日)第[\d,]+节\{第(\d+)-(\d+)周\}$"#, options: .regularExpression) {
                            let fullMatch = String(timeInfo[timeMatch])
                            
                            // 提取星期
                            if let weekdayMatch = fullMatch.range(of: #"^(周一|周二|周三|周四|周五|周六|周日)"#, options: .regularExpression) {
                                let weekdayStr = String(fullMatch[weekdayMatch])
                                guard let week = weekdayMap[weekdayStr] else { continue }
                                
                                // 提取节次
                                if let periodsMatch = fullMatch.range(of: #"第([\d,]+)节"#, options: .regularExpression) {
                                    let periodsStr = String(fullMatch[periodsMatch])
                                        .replacingOccurrences(of: "第", with: "")
                                        .replacingOccurrences(of: "节", with: "")
                                    let periods = periodsStr.components(separatedBy: ",")
                                        .compactMap { Int($0) }
                                    
                                    if !periods.isEmpty {
                                        maxPeriod = max(maxPeriod, periods.max() ?? maxPeriod)
                                        
                                        // 提取周数范围
                                        if let weekRangeMatch = fullMatch.range(of: #"\{第(\d+)-(\d+)周\}"#, options: .regularExpression) {
                                            let weekRangeStr = String(fullMatch[weekRangeMatch])
                                            let numbers = weekRangeStr.components(separatedBy: CharacterSet.decimalDigits.inverted)
                                                .compactMap { Int($0) }
                                            
                                            if numbers.count >= 2 {
                                                let startWeek = numbers[0]
                                                let endWeek = numbers[1]
                                                
                                                let course = ParsedCourse(
                                                    name: courseName,
                                                    teacher: teacher,
                                                    classroom: classroom,
                                                    week: week,
                                                    times: periods,
                                                    startWeek: startWeek,
                                                    endWeek: endWeek
                                                )
                                                courses.append(course)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        i += 4
                    } else {
                        i += 1
                    }
                }
            }
        }
        
        // 去重
        let uniqueCourses = Array(Set(courses))
        return (uniqueCourses, maxPeriod)
    }
}

// 安全索引扩展
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

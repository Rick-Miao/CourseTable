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
        print("开始解析")
        guard let doc = try? SwiftSoup.parse(html) else {
            print("HTML 解析失败")
            throw ScheduleParseError.invalidHTML
        }
        
        // 查找 Table1
        guard let table = try? doc.getElementById("Table1") else {
            print("未找到 id='Table1' 的表格")
            throw ScheduleParseError.tableNotFound
        }
        print("找到 Table1 表格")
        let rows = try table.select("tr")
        print("表格总行数: \(rows.count)")
        
        guard rows.count > 1 else {
            print("表格行数不足（需要 >1）")
            throw ScheduleParseError.tableNotFound
        }
        
        let numRows = rows.count - 1  // 跳过表头
        let numCols = 9               // 时间类型 + 节次 + 7天
        var grid: [[Element?]] = Array(repeating: Array(repeating: nil, count: numCols), count: numRows)
        
        print("初始化网格: \(numRows) 行 × \(numCols) 列")
        
        // 填充网格（处理 rowspan/colspan）
        for i in 0..<numRows {
            let row = rows[i + 1]  // 跳过表头
            let cells = try row.select("td,th")
            print("  行 \(i): 找到 \(cells.count) 个单元格")
            
            var j = 0
            var cellIndex = 0
            
            while j < numCols && cellIndex < cells.count {
                if grid[i][j] != nil {
                    j += 1
                    continue
                }
                
                let cell = cells[cellIndex]
                cellIndex += 1
                
                let rowspan = Int((try? cell.attr("rowspan")) ?? "1") ?? 1
                let colspan = Int((try? cell.attr("colspan")) ?? "1") ?? 1
                
                print("    单元格[\(i),\(j)]: rowspan=\(rowspan), colspan=\(colspan)")
                
                for r in i..<(min(i + rowspan, numRows)) {
                    for c in j..<(min(j + colspan, numCols)) {
                        grid[r][c] = cell
                    }
                }
                
                j += colspan
            }
        }
        
        // 提取课程数据
        var courses: [ParsedCourse] = []
        var maxPeriod = 12
        
        let weekdayMap: [String: Int] = [
            "周一": 1, "周二": 2, "周三": 3, "周四": 4,
            "周五": 5, "周六": 6, "周日": 7
        ]
        
        print("开始提取课程数据...")
        
        for rowIdx in 0..<numRows {
            for colIdx in 2..<min(9, numCols) {
                guard let cell = grid[rowIdx][colIdx] else { continue }

                // 获取原始 HTML
                let htmlText = try cell.html()
                let fullText = htmlText
                    .replacingOccurrences(of: "<br\\s*[^>]*>", with: "\n", options: .regularExpression)
                    .replacingOccurrences(of: "&nbsp;", with: " ")
                    .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                guard !fullText.isEmpty && fullText != " " else { continue }
                
                print("  单元格[\(rowIdx),\(colIdx)]: 内容长度=\(fullText.count)")
                print("    原始内容: \(fullText.replacingOccurrences(of: "\n", with: " | "))")
                
                let pattern = #"([^\n]+)\n(周一|周二|周三|周四|周五|周六|周日)第([\d,]+)节\{第(\d+)-(\d+)周(?:\|[^}]+)?\}\n([^\n]+)\n([^\n]+)"#
                do {
                    let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
                    let nsString = fullText as NSString
                    let matches = regex.matches(in: fullText, range: NSRange(location: 0, length: nsString.length))
                    
                    print("    找到 \(matches.count) 门课程")
                    
                    for match in matches {
                        let courseName = nsString.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
                        let weekdayStr = nsString.substring(with: match.range(at: 2))
                        let periodsStr = nsString.substring(with: match.range(at: 3))
                        let startWeekStr = nsString.substring(with: match.range(at: 4))
                        let endWeekStr = nsString.substring(with: match.range(at: 5))
                        let teacher = nsString.substring(with: match.range(at: 6)).trimmingCharacters(in: .whitespaces)
                        let classroom = nsString.substring(with: match.range(at: 7)).trimmingCharacters(in: .whitespaces)
                        
                        print("      课程名: \(courseName)")
                        print("      时间: \(weekdayStr)第\(periodsStr)节{第\(startWeekStr)-\(endWeekStr)周}")
                        print("      教师: \(teacher)")
                        print("      教室: \(classroom)")
                        
                        guard let week = weekdayMap[weekdayStr],
                              let startWeek = Int(startWeekStr),
                              let endWeek = Int(endWeekStr) else {
                            print("      星期或周次转换失败")
                            continue
                        }
                        
                        let periods = periodsStr.components(separatedBy: ",")
                            .compactMap { Int($0) }
                        
                        if !periods.isEmpty {
                            maxPeriod = max(maxPeriod, periods.max() ?? maxPeriod)
                            
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
                            print("      成功解析课程")
                        } else {
                            print("      节次解析失败")
                        }
                    }
                } catch {
                    print("    正则错误: \(error)")
                }
            }
        }
        
        print("总共解析到 \(courses.count) 门课程")
        
        // 去重
        let uniqueCourses = Array(Set(courses))
        print("去重后: \(uniqueCourses.count) 门课程")
        return (uniqueCourses, maxPeriod)
    }
}

// 安全索引扩展
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

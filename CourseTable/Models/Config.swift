//
//  Config.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/19.
//

import Foundation

struct Config: Codable {
    let semesterStart: String  // 格式: "yyyy-MM-dd"
    let totalWeeks: Int
    let periods: [Period]
    
    struct Period: Codable, Identifiable {
        var id: String { period }
        let period: String
        let startTime: String
        let endTime: String
    }
}

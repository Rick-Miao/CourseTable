//
//  CourseStruct.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

struct Course: Codable, Identifiable, Equatable {
    var id: String {
        "\(name)_\(teacher)_\(week)_\(times.first ?? 0)_\(startWeek)_\(endWeek)"
    }
    let name: String
    let teacher: String
    let classroom: String
    let week: Int
    let times: [Int]
    let startWeek: Int
    let endWeek: Int
}

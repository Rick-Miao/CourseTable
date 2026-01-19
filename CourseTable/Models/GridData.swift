//
//  GridData.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/19.
//

import Foundation

struct DayColumn {
    let day: Int
    var cells: [CellItem] = []
}

enum CellItem {
    case course(Course, span: Int)
    case empty
}

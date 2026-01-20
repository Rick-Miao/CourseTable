//
//  FileHelper.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/20.
//

import Foundation

enum FileHelper {
    static var courseDataDirectory: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("courseData", isDirectory: true)
    }
    
    static func ensureCourseDataDirectoryExists() {
        if !FileManager.default.fileExists(atPath: courseDataDirectory.path) {
            try? FileManager.default.createDirectory(at: courseDataDirectory, withIntermediateDirectories: true)
        }
    }
}

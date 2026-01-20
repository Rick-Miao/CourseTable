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
    
    static func saveCourseData(_ data: Data, name: String) {
        ensureCourseDataDirectoryExists()
        let safeName = name.replacingOccurrences(of: "/", with: "_")
        let fileURL = courseDataDirectory.appendingPathComponent("\(safeName).json")
        try? data.write(to: fileURL)
    }
}

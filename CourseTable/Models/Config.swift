//
//  Config.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/19.
//

import Foundation

struct Config: Codable {
    var semesterStart: String  // 格式: "yyyy-MM-dd"
    var totalWeeks: Int
    var periods: [Period]
    
    struct Period: Codable, Identifiable {
        var id = UUID().uuidString
        var period: String
        var startTime: String
        var endTime: String
        
        // 成员初始化器
        init(period: String, startTime: String, endTime: String) {
            self.period = period
            self.startTime = startTime
            self.endTime = endTime
        }
        
        // 兼容旧 JSON
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            period = try container.decode(String.self, forKey: .period)
            startTime = try container.decode(String.self, forKey: .startTime)
            endTime = try container.decode(String.self, forKey: .endTime)
            id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        }
        
        enum CodingKeys: String, CodingKey {
            case id, period, startTime, endTime
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(period, forKey: .period)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(endTime, forKey: .endTime)
        }
    }
}

struct ConfigWrapper: Codable {
    var config: Config
    var courses: [Course]
}

//
//  PeriodEditView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/20.
//

import SwiftUI

struct PeriodEditView: View {
    @Binding var periods: [Config.Period]
    @State private var expandedStartTimeIndex: Int? = nil
    @State private var expandedEndTimeIndex: Int? = nil
    
    var body: some View {
        List {
            ForEach(0..<periods.count, id: \.self) { index in
                Section {
                    HStack {
                        Text("第 \(periods[index].period) 节")
                            .font(.body)
                        
                        Spacer()
                        
                        Button(action: {
                            // 切换展开状态
                            if expandedStartTimeIndex == index {
                                expandedStartTimeIndex = nil
                            } else {
                                expandedStartTimeIndex = index
                                expandedEndTimeIndex = nil // 关闭结束时间
                            }
                        }) {
                            Text(periods[index].startTime)
                                .foregroundColor(.blue)
                                .frame(width: 60, alignment: .trailing)
                        }
                        .buttonStyle(.plain)
                        
                        Text(" - ")
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // 切换展开状态
                            if expandedEndTimeIndex == index {
                                expandedEndTimeIndex = nil
                            } else {
                                expandedEndTimeIndex = index
                                expandedStartTimeIndex = nil // 关闭开始时间
                            }
                        }) {
                            Text(periods[index].endTime)
                                .foregroundColor(.blue)
                                .frame(width: 60, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    
                    // 👇 开始时间 DatePicker（内联）
                    if expandedStartTimeIndex == index {
                        DatePicker(
                            "开始时间",
                            selection: Binding(
                                get: { parseTime(periods[index].startTime) },
                                set: { newTime in
                                    periods[index].startTime = formatTime(newTime)
                                }
                            ),
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                    
                    // 👇 结束时间 DatePicker（内联）
                    if expandedEndTimeIndex == index {
                        DatePicker(
                            "结束时间",
                            selection: Binding(
                                get: { parseTime(periods[index].endTime) },
                                set: { newTime in
                                    periods[index].endTime = formatTime(newTime)
                                }
                            ),
                            displayedComponents: [.hourAndMinute]
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                    }
                }
            }
            .onDelete(perform: deletePeriods)
            
            Section {
                Button("添加新节次") {
                    addNewPeriod()
                }
            }
        }
        .navigationTitle("上课时间")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func addNewPeriod() {
        let newPeriod = Config.Period(
            period: "\(periods.count + 1)",
            startTime: "08:00",
            endTime: "08:45"
        )
        periods.append(newPeriod)
    }
    
    private func deletePeriods(at offsets: IndexSet) {
        periods.remove(atOffsets: offsets)
        // 更新节次编号
        for i in 0..<periods.count {
            periods[i].period = "\(i + 1)"
        }
    }
    private func parseTime(_ timeString: String) -> Date {
        return DateFormatter.HHmm.date(from: timeString) ?? Date()
    }
    
    // 时间格式化
    private func formatTime(_ date: Date) -> String {
        return DateFormatter.HHmm.string(from: date)
    }
}

// 时间选择器组件
struct TimePickerView: View {
    let title: String
    @Binding var currentTime: Date
    let onDismiss: () -> Void
    
    var body: some View {
            VStack(spacing: 16) {
                Text(title)
                    .font(.headline)
                    .padding(.top, 8)
                
                DatePicker(
                    "",
                    selection: $currentTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .frame(height: 120)
                
                HStack {
                    Button("取消") {
                        onDismiss()
                    }
                    .tint(.secondary)
                    
                    Spacer()
                    
                    Button("确定") {
                        onDismiss()
                    }
                    .tint(.primary)
                }
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .frame(width: 280, height: 220)
        }
}

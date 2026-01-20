//
//  PeriodEditView.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/20.
//

import SwiftUI

struct PeriodEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var periods: [Config.Period]
    @State private var showingStartTimePicker = false
    @State private var showingEndTimePicker = false
    @State private var selectedPeriodIndex = 0
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<periods.count, id: \.self) { index in
                    HStack {
                        Text("第 \(periods[index].period) 节")
                            .font(.body)
                        
                        Spacer()
                        
                        // 开始时间
                        Button(action: {
                            selectedPeriodIndex = index
                            showingStartTimePicker = true
                        }) {
                            Text(periods[index].startTime)
                                .foregroundColor(.blue)
                                .frame(minWidth: 60, alignment: .trailing)
                        }
                        .buttonStyle(.plain)
                        
                        Text(" - ")
                            .foregroundColor(.secondary)
                        
                        // 结束时间
                        Button(action: {
                            selectedPeriodIndex = index
                            showingEndTimePicker = true
                        }) {
                            Text(periods[index].endTime)
                                .foregroundColor(.blue)
                                .frame(minWidth: 60, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
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
            
            // 开始时间选择器
            .sheet(isPresented: $showingStartTimePicker) {
                TimePickerView(
                    title: "开始时间",
                    currentTime: Binding(
                        get: { parseTime(periods[selectedPeriodIndex].startTime) },
                        set: { newTime in
                            periods[selectedPeriodIndex].startTime = formatTime(newTime)
                        }
                    )
                )
            }
            
            // 结束时间选择器
            .sheet(isPresented: $showingEndTimePicker) {
                TimePickerView(
                    title: "结束时间",
                    currentTime: Binding(
                        get: { parseTime(periods[selectedPeriodIndex].endTime) },
                        set: { newTime in
                            periods[selectedPeriodIndex].endTime = formatTime(newTime)
                        }
                    )
                )
            }
        }
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
    
    // 时间解析
    private func parseTime(_ timeString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: timeString) ?? Date()
    }
    
    // 时间格式化
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// 时间选择器组件
struct TimePickerView: View {
    let title: String
    @Binding var currentTime: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "",
                    selection: $currentTime,
                    displayedComponents: [.hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .padding()
                
                Button("完成") {
                    dismiss()
                }
                .font(.headline)
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

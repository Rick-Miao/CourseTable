//
//  EmptyCell.swift
//  CourseTable
//
//  Created by Xiaobei on 2026/1/18.
//

import SwiftUI

struct EmptyCellView: View {
    var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(Color(.separator)),
                alignment: .trailing
            )
    }
}

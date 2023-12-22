//  MemoRowView.swift

import SwiftUI

struct MemoRowView: View {
    let memo: Memo

    var body: some View {
        HStack {
            Image(systemName: memo.isPurchased ? "checkmark.circle.fill" : "circle")
                .foregroundColor(memo.isPurchased ? .green : .secondary)
            
            VStack(alignment: .leading) {
                Text(memo.name)
                    .font(.headline)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("\(memo.quantity) \(memo.unit) • \(formattedDate(memo.needBy)) • \(memo.priority)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd"
        return dateFormatter.string(from: date)
    }
}

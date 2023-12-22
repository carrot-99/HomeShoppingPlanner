//  EditCategoryView.swift

import SwiftUI

struct EditCategoryView: View {
    @Binding var category: String
    @Binding var newName: String
    @Binding var isNewCategory: Bool
    var saveAction: () -> Void

    var body: some View {
        Form {
            TextField(isNewCategory ? "新しいカテゴリ名" : "カテゴリ名を編集", text: $newName)
            Button("保存", action: saveAction)
                .disabled(newName.isEmpty)
        }
    }
}

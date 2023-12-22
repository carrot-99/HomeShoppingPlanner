//  EditUnitView.swift

import SwiftUI

struct EditUnitView: View {
    @Binding var unit: String
    @Binding var newName: String
    @Binding var isNewUnit: Bool
    var saveAction: () -> Void

    var body: some View {
        Form {
            TextField(isNewUnit ? "新しい単位名" : "単位名を編集", text: $newName)
            Button("保存", action: saveAction)
                .disabled(newName.isEmpty)
        }
    }
}

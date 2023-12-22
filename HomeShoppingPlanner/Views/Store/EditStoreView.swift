//  EditStoreView.swift

import SwiftUI

struct EditStoreView: View {
    let storeId: UUID
    @Binding var storeName: String
    var onSave: (String) -> Void
    var onDelete: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            TextField("店名", text: $storeName)
            Button("保存") {
                onSave(storeName)
                presentationMode.wrappedValue.dismiss()
            }
            
            Button("削除", role: .destructive) {
                onDelete()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationTitle("店名を編集")
        .onAppear {
            print("EditStoreView appeared with storeID: \(storeId), storeName: \(storeName)")
        }
    }
}

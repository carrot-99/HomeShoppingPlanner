//  TopBarView.swift

import SwiftUI

struct TopBarView: View {
    @Binding var newStoreName: String
    var addStoreAction: () -> Void

    var body: some View {
        HStack {
            TextField("新しい店名を追加", text: $newStoreName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: addStoreAction) {
                Image(systemName: "plus")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
            .padding(.leading, 10)
        }
        .padding()
    }
}

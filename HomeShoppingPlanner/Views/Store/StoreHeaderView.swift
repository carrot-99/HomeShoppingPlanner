//  StoreHeaderView.swift

import SwiftUI

struct StoreHeaderView: View {
    let store: Store
    var onAddMemo: () -> Void
    var onEditStore: () -> Void

    var body: some View {
        HStack {
            Text(store.name)
            Spacer()
            Button(action: onEditStore) {
                Image(systemName: "pencil")
                    .imageScale(.small)
            }
            Button(action: onAddMemo) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
    }
}

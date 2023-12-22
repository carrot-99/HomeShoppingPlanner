//  StoreSectionView.swift

import Foundation
import SwiftUI

struct StoreSection: View {
    let store: Store
    @ObservedObject var viewModel: HomeViewModel
    @Binding var editingStoreId: UUID?
    @Binding var showingEditStore: Bool
    @Binding var isDataLoaded: Bool

    var body: some View {
        Section(header: StoreHeaderView(
            store: store,
            onAddMemo: {
                viewModel.addMemo(
                    to: store.id,
                    memo: Memo(
                        storeId: store.id,
                        name: "",
                        quantity: 1,
                        unit: "個",
                        needBy: Date(),
                        priority: "中"
                    )
                )
            },
            onEditStore: {
                print("Before opening EditStoreView - Store ID: \(store.id)")
                if viewModel.isDataLoaded {
                    print("Edit button tapped - Store ID: \(store.id)")
                    self.editingStoreId = store.id
                    self.showingEditStore = true
                } else {
                    // データがロードされていない場合の処理（エラーメッセージの表示など）
                    viewModel.alertMessage = "データがロードされていません。しばらくお待ちください。"
                    viewModel.showAlert = true                }
            }
        )) {
            ForEach(store.memos) { memo in
                if let storeIndex = viewModel.stores.firstIndex(where: { $0.id == store.id }),
                   let memoIndex = store.memos.firstIndex(where: { $0.id == memo.id }) {
                    NavigationLink(destination: MemoDetailView(memo: $viewModel.stores[storeIndex].memos[memoIndex], viewModel: viewModel)) {
                        MemoRowView(memo: memo)
                    }
                }
            }
            .onDelete { offsets in
                if let storeIndex = viewModel.stores.firstIndex(where: { $0.id == store.id }) {
                    offsets.forEach { index in
                        if index < viewModel.stores[storeIndex].memos.count {
                            let memoId = viewModel.stores[storeIndex].memos[index].id
                            viewModel.deleteMemo(storeId: store.id, memoId: memoId)
                        }
                    }
                }
            }
        }
    }
}

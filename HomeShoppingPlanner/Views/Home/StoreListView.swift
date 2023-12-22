//  StoreListView.swift

import SwiftUI

struct StoreListView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var editingStoreId: UUID?
    @Binding var showingEditStore: Bool
    @Binding var isDataLoaded: Bool

    var body: some View {
        List {
            ForEach(viewModel.stores) { store in
                StoreSection(store: store, viewModel: viewModel, editingStoreId: $editingStoreId, showingEditStore: $showingEditStore, isDataLoaded: $isDataLoaded)
            }
        }
        .onAppear {
            print("StoreListView appeared - editingStoreId: \(String(describing: editingStoreId))")
        }
    }
}

// HomeView.swift

import SwiftUI

struct HomeView: View {
    @State private var newStoreName: String = ""
    @State private var editingStoreId: UUID?
    @State private var showingEditStore = false
    @State private var isMenuOpen: Bool = false
    @State private var isDataLoaded = false
    @ObservedObject var authViewModel: AuthenticationViewModel
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        ZStack(alignment: .leading) {
            NavigationView {
                VStack {
                    TopBarView(newStoreName: $newStoreName, addStoreAction: {
                        viewModel.addStore(name: newStoreName)
                        newStoreName = ""
                    })
                    
                    StoreListView(viewModel: viewModel, editingStoreId: $editingStoreId, showingEditStore: $showingEditStore, isDataLoaded: $isDataLoaded)
                }
                .navigationTitle("買い物メモ")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            self.isMenuOpen.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3")
                        }
                    }
                }
                .sheet(isPresented: $showingEditStore, onDismiss: {
                    self.editingStoreId = nil
                    self.isDataLoaded = false
                }) {
                    if let editingStoreId = editingStoreId,
                       let storeIndex = viewModel.stores.firstIndex(where: { $0.id == editingStoreId }) {
                        EditStoreView(
                            storeId: editingStoreId,
                            storeName: $viewModel.stores[storeIndex].name,
                            onSave: { newName in
                                viewModel.updateStore(storeId: editingStoreId, newName: newName)
                            },
                            onDelete: {
                                let indexSet = IndexSet(integer: storeIndex)
                                viewModel.deleteStore(storeId: editingStoreId)
                            }
                        )
                    } else {
                        Text("店舗が見つかりません。\n再度お試しください。")
                            .onAppear {
                                print("EditStoreView attempted to open with non-existent storeID: \(String(describing: editingStoreId))")
                            }
                    }
                }
            }
            
            if isMenuOpen {
                SideMenuView(isMenuOpen: $isMenuOpen)
                    .frame(width: 250)
                    .transition(.move(edge: .leading))
            }
            
            VStack {
                Spacer()
                
                if !authViewModel.isEmailVerified && authViewModel.isAuthenticated {
                    AlertView()
                }
            }
        }
        .onAppear {
            viewModel.fetchStores()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("エラー"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK")) {
                    viewModel.showAlert = false
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func AlertView() -> some View {
        VStack {
            Text("メールアドレスが未確認です")
                .font(.headline)
                .foregroundColor(.red)
                .padding()
            Text("アカウントを使用するにはメールアドレスの確認が必要です。登録されたメールアドレスを確認し、メールに含まれるリンクをクリックしてください。")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            Button("確認状態を更新") {
                authViewModel.refreshEmailVerificationStatus()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
}

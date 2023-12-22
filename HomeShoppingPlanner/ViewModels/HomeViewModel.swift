// HomeViewModel.swift

import SwiftUI
import CoreData
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @Published var stores: [Store] = []
    @Published var categories: [String] = []
    @Published var units: [String] = []
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var isDataLoaded = false
    private var storeManager: StoreManager
    private var memoManager: MemoManager
    private var categoryManager: CategoryManager
    private var unitManager: UnitManager
    private var authManager: AuthenticationManager
    
    var isAuthenticated: Bool {
        // ユーザーの認証状態を返すロジックを実装
        return Auth.auth().currentUser != nil
    }

    init(context: NSManagedObjectContext) {
        storeManager = StoreManager(context: context)
        memoManager = MemoManager(context: context)
        categoryManager = CategoryManager(context: context)
        unitManager = UnitManager(context: context)
        authManager = AuthenticationManager()

        initializeData()
    }

    private func initializeData() {
        fetchStores()
        fetchCategoriesAndUnits()
    }

    func fetchStores(completion: (() -> Void)? = nil) {
        storeManager.fetchStores { stores in
            DispatchQueue.main.async {
                self.stores = stores
                self.isDataLoaded = true
                print("Data is now loaded.")
                completion?()
            }
        }
    }

    private func fetchCategoriesAndUnits() {
        categoryManager.fetchCategories { categories in
            DispatchQueue.main.async {
                self.categories = categories
            }
        }

        unitManager.fetchUnits { units in
            DispatchQueue.main.async {
                self.units = units
            }
        } 
    }
    
    func refreshStoreData(storeId: UUID) {
        storeManager.refreshStoreData(storeId: storeId) { store in
            if let store = store, let index = self.stores.firstIndex(where: { $0.id == store.id }) {
                self.stores[index] = store
            }
        }
    }

    func addStore(name: String) {
        storeManager.addStore(name) { success in
            if success {
                self.fetchStores()
            } else {
                self.alertMessage = "Failed to add store."
                self.showAlert = true
            }
        }
    }
    
    func updateStore(storeId: UUID, newName: String) {
        storeManager.updateStore(id: storeId, newName: newName) { success in
            if success {
                self.fetchStores()
            } else {
                self.alertMessage = "Failed to update store."
                self.showAlert = true
            }
        }
    }
    
    func deleteStore(storeId: UUID) {
        storeManager.deleteStore(at: storeId) { success in
            if success {
                self.fetchStores()
            } else {
                self.alertMessage = "Failed to delete store."
                self.showAlert = true
            }
        }
    }
    
    func addMemo(to storeId: UUID, memo: Memo) {
        memoManager.addMemo(to: storeId, memo: memo) { success in
            if success {
                self.refreshStoreData(storeId: storeId)
            } else {
                self.alertMessage = "Failed to add memo."
                self.showAlert = true
            }
        }
    }
    
    func updateMemo(storeId: UUID, memoId: UUID, updatedMemo: Memo) {
        memoManager.updateMemo(in: storeId, memoId: memoId, with: updatedMemo) { success in
            if success {
                self.fetchStores()
            } else {
                self.alertMessage = "Failed to update memo."
                self.showAlert = true
            }
        }
    }
    
    func deleteMemo(storeId: UUID, memoId: UUID) {
        memoManager.deleteMemo(from: storeId, at: memoId) { success in
            if success {
                self.refreshStoreData(storeId: storeId)
            } else {
                self.alertMessage = "Failed to delete memo."
                self.showAlert = true
            }
        }
    }
    
    func updateMemoWithImage(storeId: UUID, memoId: UUID, imageURL: String, imageData: Data) {
        memoManager.fetchMemos(storeId: storeId) { memos in
            if let index = memos.firstIndex(where: { $0.id == memoId }) {
                var updatedMemo = memos[index]
                updatedMemo.imageURL = imageURL  // Firebase用の画像URLをセット
                updatedMemo.imageData = imageData  // CoreData用の画像データをセット
                self.updateMemo(storeId: storeId, memoId: memoId, updatedMemo: updatedMemo)
            }
        }
    }

    
    func addCategory(name: String) {
        categoryManager.addCategory(name) { success in
            if success {
                self.fetchCategoriesAndUnits()
            } else {
                self.alertMessage = "Failed to add category."
                self.showAlert = true
            }
        }
    }
    
    func updateCategory(oldName: String, newName: String) {
        categoryManager.updateCategory(oldName: oldName, newName: newName) { success in
            if success {
                self.fetchCategoriesAndUnits()
            } else {
                self.alertMessage = "Failed to update category."
                self.showAlert = true
            }
        }
    }
    
    func deleteCategory(name: String) {
        categoryManager.deleteCategory(name) { success in
            if success {
                self.fetchCategoriesAndUnits()
            } else {
                self.alertMessage = "Failed to delete category."
                self.showAlert = true
            }
        }
    }
    
    func addUnit(name: String) {
        unitManager.addUnit(name) { success in
            if success {
                self.fetchCategoriesAndUnits()
            } else {
                self.alertMessage = "Failed to add unit."
                self.showAlert = true
            }
        }
    }
    
    func updateUnit(oldName: String, newName: String) {
        unitManager.updateUnit(oldName: oldName, newName: newName) { success in
            if success {
                self.fetchCategoriesAndUnits()
            } else {
                self.alertMessage = "Failed to update unit."
                self.showAlert = true
            }
        }
    }
    
    func deleteUnit(name: String) {
        unitManager.deleteUnit(name) { success in
            if success {
                self.fetchCategoriesAndUnits()
            } else {
                self.alertMessage = "Failed to delete unit."
                self.showAlert = true
            }
        }
    }
    
    func resetViewModel() {
        stores = []
        categories = []
        units = []
    }
}

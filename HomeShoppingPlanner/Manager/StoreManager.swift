//  StoreManager.swift

import CoreData
import FirebaseFirestore
import FirebaseAuth

class StoreManager {
    private var firestoreStoreService = FirestoreStoreService()
    private var coreDataStoreService: CoreDataStoreService
    private var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }

    init(context: NSManagedObjectContext) {
        self.coreDataStoreService = CoreDataStoreService(context: context)
    }

    func addStore(_ name: String, completion: @escaping (Bool) -> Void) {
        let newStoreId = UUID()
        let newStore = Store(id: newStoreId, name: name, memos: [])

        if isAuthenticated {
            firestoreStoreService.addStore(newStore) { success, _ in
                if success {
                    self.coreDataStoreService.addStore(withId: newStoreId, name: name)
                }
                completion(success)
            }
        } else {
            coreDataStoreService.addStore(withId: newStoreId, name: name)
            completion(true)
        }
    }

    func updateStore(id storeId: UUID, newName: String, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            let updatedStore = Store(id: storeId, name: newName, memos: [])
            firestoreStoreService.updateStore(updatedStore) { success, _ in
                if success {
                    self.coreDataStoreService.updateStore(id: storeId, newName: newName)
                }
                completion(success)
            }
        } else {
            coreDataStoreService.updateStore(id: storeId, newName: newName)
            completion(true)
        }
    }

    func deleteStore(at storeId: UUID, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreStoreService.deleteStore(storeId) { success, _ in
                if success {
                    self.coreDataStoreService.deleteStore(withId: storeId) { success in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            coreDataStoreService.deleteStore(withId: storeId) { success in
                completion(success)
            }
        }
    }

    func fetchStores(completion: @escaping ([Store]) -> Void) {
        if isAuthenticated {
            firestoreStoreService.fetchStores { stores, _ in
                completion(stores)
            }
        } else {
            coreDataStoreService.fetchStores { stores in
                completion(stores)
            }
        }
    }

    func refreshStoreData(storeId: UUID, completion: @escaping (Store?) -> Void) {
        if isAuthenticated {
            firestoreStoreService.fetchStore(storeId: storeId) { store, _ in
                completion(store)
            }
        } else {
            coreDataStoreService.fetchStore(storeId: storeId) { store in
                completion(store)
            }
        }
    }
}

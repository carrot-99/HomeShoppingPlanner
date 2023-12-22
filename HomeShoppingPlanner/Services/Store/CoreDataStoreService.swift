//  CoreDataStoreService.swift

import Foundation
import CoreData

class CoreDataStoreService {
    @Published var stores: [Store] = []
    private var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchStores(completion: @escaping ([Store]) -> Void) {
        let fetchRequest: NSFetchRequest<CDStore> = CDStore.fetchRequest()
        do {
            let storeEntities = try context.fetch(fetchRequest)
            var fetchedStores: [Store] = []
            for storeEntity in storeEntities {
//                print("Store Name: \(storeEntity.name ?? "Unknown Name")\nid:\(String(describing: storeEntity.id))")
                if let memosSet = storeEntity.memos as? Set<CDMemo> {
                    for memoEntity in memosSet {
//                        print("Memo Name: \(memoEntity.name ?? "Unknown Name")")
                    }
                }
                let memos: [Memo] = (storeEntity.memos as? Set<CDMemo> ?? []).compactMap { Memo(entity: $0) }
                let store = Store(id: UUID(uuidString: storeEntity.id ?? "") ?? UUID(), name: storeEntity.name ?? "", memos: memos)
                fetchedStores.append(store)
            }
            DispatchQueue.main.async {
                self.stores = fetchedStores
            }
            completion(fetchedStores)
        } catch {
            print("Error fetching stores: \(error)")
        }
    }
    
    func fetchStore(storeId: UUID, completion: @escaping (Store?) -> Void) {
        let fetchRequest: NSFetchRequest<CDStore> = CDStore.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", storeId.uuidString)

        do {
            let storeEntities = try context.fetch(fetchRequest)
            if let storeEntity = storeEntities.first {
                let memos: [Memo] = (storeEntity.memos as? Set<CDMemo> ?? []).compactMap { Memo(entity: $0) }
                let store = Store(id: storeId, name: storeEntity.name ?? "", memos: memos)
                completion(store)
            } else {
                completion(nil)
            }
        } catch {
            print("Error fetching store: \(error)")
            completion(nil)
        }
    }
    
    func addStore(withId id: UUID, name: String) {
        let newStoreEntity = CDStore(context: context)
        newStoreEntity.id = id.uuidString
        newStoreEntity.name = name

        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }

    func updateStore(id storeId: UUID, newName: String) {
        let fetchRequest: NSFetchRequest<CDStore> = CDStore.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", storeId.uuidString)

        do {
            let storeEntities = try context.fetch(fetchRequest)
            if let storeEntityToUpdate = storeEntities.first {
                storeEntityToUpdate.name = newName
                try context.save()
            }
        } catch {
            print("Error updating store: \(error)")
        }
    }
    
    func deleteStore(withId storeId: UUID, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<CDStore> = CDStore.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", storeId.uuidString)

        do {
            let storeEntities = try context.fetch(fetchRequest)
            if let storeEntityToDelete = storeEntities.first {
                context.delete(storeEntityToDelete)
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Error deleting store: \(error)")
            completion(false)
        }
    }
}

//  CoreDataMemoService.swift

import CoreData

class CoreDataMemoService {
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchMemos(storeId: UUID, completion: @escaping ([Memo]) -> Void) {
        let fetchRequest: NSFetchRequest<CDMemo> = CDMemo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "store.id == %@", storeId as CVarArg)

        do {
            let memoEntities = try context.fetch(fetchRequest)
            let memos = memoEntities.map { Memo(entity: $0) }
            completion(memos)
        } catch {
            print("Error fetching memos: \(error)")
            completion([])
        }
    }

    func addMemo(to storeId: UUID, memo: Memo, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<CDStore> = CDStore.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", storeId.uuidString)

        do {
            let storeEntities = try context.fetch(fetchRequest)
            if let storeEntity = storeEntities.first {
                let newMemoEntity = CDMemo(context: context)
                newMemoEntity.id = memo.id.uuidString
                newMemoEntity.name = memo.name
                newMemoEntity.quantity = Int64(memo.quantity)
                newMemoEntity.unit = memo.unit
                newMemoEntity.needBy = memo.needBy
                newMemoEntity.priority = memo.priority
                newMemoEntity.isPurchased = memo.isPurchased
                newMemoEntity.category = memo.category
                newMemoEntity.note = memo.note
                newMemoEntity.imageData = memo.imageData
                newMemoEntity.imageURL = memo.imageURL
                storeEntity.addToMemos(newMemoEntity)
                
                do {
                    try context.save()
                    completion(true)
                } catch {
                    print("Error saving context: \(error)")
                    completion(false)
                }
            } else {
                print("Failed to find store entity in CoreData for storeId: \(storeId)")
                completion(false)
            }
        } catch {
            print("Error fetching store entity: \(error)")
            completion(false)
        }
    }

    func updateMemo(in storeId: UUID, memoId: UUID, with updatedMemo: Memo, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<CDMemo> = CDMemo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", memoId.uuidString)

        do {
            let memoEntities = try context.fetch(fetchRequest)
            if let memoEntityToUpdate = memoEntities.first {
                // メモの属性を更新
                memoEntityToUpdate.name = updatedMemo.name
                memoEntityToUpdate.quantity = Int64(updatedMemo.quantity)
                memoEntityToUpdate.unit = updatedMemo.unit
                memoEntityToUpdate.needBy = updatedMemo.needBy
                memoEntityToUpdate.priority = updatedMemo.priority
                memoEntityToUpdate.isPurchased = updatedMemo.isPurchased
                memoEntityToUpdate.category = updatedMemo.category
                memoEntityToUpdate.note = updatedMemo.note
                memoEntityToUpdate.imageData = updatedMemo.imageData
                memoEntityToUpdate.imageURL = updatedMemo.imageURL

                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Error updating memo: \(error)")
            completion(false)
        }
    }

    func deleteMemo(from storeId: UUID, memoId: UUID, completion: @escaping (Bool) -> Void) {
        let fetchRequest: NSFetchRequest<CDMemo> = CDMemo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", memoId.uuidString)
        
        do {
            if let memoEntities = try? context.fetch(fetchRequest),
               let memoEntityToDelete = memoEntities.first {
                context.delete(memoEntityToDelete)
                try context.save()
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Error deleting memo: \(error)")
            completion(false)
        }
    }
}

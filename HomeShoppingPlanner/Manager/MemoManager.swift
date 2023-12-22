//  MemoManager.swift

import CoreData
import FirebaseFirestore
import FirebaseAuth

class MemoManager {
    private var firestoreMemoService = FirestoreMemoService()
    private var coreDataMemoService: CoreDataMemoService
    private var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }

    init(context: NSManagedObjectContext) {
        self.coreDataMemoService = CoreDataMemoService(context: context)
    }

    func addMemo(to storeId: UUID, memo: Memo, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreMemoService.addMemo(storeId: storeId, memo: memo) { success, _ in
                if success {
                    self.coreDataMemoService.addMemo(to: storeId, memo: memo) { success in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            coreDataMemoService.addMemo(to: storeId, memo: memo) { success in
                completion(success)
            }
        }
    }

    func updateMemo(in storeId: UUID, memoId: UUID, with updatedMemo: Memo, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreMemoService.updateMemo(storeId: storeId, memo: updatedMemo) { success, _ in
                if success {
                    self.coreDataMemoService.updateMemo(in: storeId, memoId: memoId, with: updatedMemo) { success in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            coreDataMemoService.updateMemo(in: storeId, memoId: memoId, with: updatedMemo) { success in
                completion(success)
            }
        }
    }

    func deleteMemo(from storeId: UUID, at memoId: UUID, completion: @escaping (Bool) -> Void) {
        if isAuthenticated {
            firestoreMemoService.deleteMemo(storeId: storeId, memoId: memoId) { success, _ in
                if success {
                    self.coreDataMemoService.deleteMemo(from: storeId, memoId: memoId) { success in
                        completion(success)
                    }
                } else {
                    completion(false)
                }
            }
        } else {
            coreDataMemoService.deleteMemo(from: storeId, memoId: memoId) { success in
                completion(success)
            }
        }
    }

    func fetchMemos(storeId: UUID, completion: @escaping ([Memo]) -> Void) {
        if isAuthenticated {
            firestoreMemoService.fetchMemos(storeId: storeId) { memos, _ in
                completion(memos)
            }
        } else {
            coreDataMemoService.fetchMemos(storeId: storeId) { memos in
                completion(memos)
            }
        }
    }
}

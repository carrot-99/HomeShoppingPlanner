//  FirestoreMemoService.swift

import FirebaseFirestore
import FirebaseAuth

class FirestoreMemoService {
    private let db = Firestore.firestore()

    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    func fetchMemos(storeId: UUID, completion: @escaping ([Memo], Error?) -> Void) {
        guard let userId = userId else {
            completion([], nil)
            return
        }

        db.collection("users").document(userId).collection("stores").document(storeId.uuidString).collection("memos").getDocuments { querySnapshot, error in
            if let error = error {
                completion([], error)
                return
            }

            var memos: [Memo] = []
            for document in querySnapshot!.documents {
                let data = document.data()
                // データをMemoオブジェクトに変換
                if let memo = Memo(data: data) {
                    memos.append(memo)
                }
            }
            completion(memos, nil)
        }
    }

    func addMemo(storeId: UUID, memo: Memo, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        let documentData: [String: Any] = memo.toDictionary()
        db.collection("users").document(userId).collection("stores").document(storeId.uuidString).collection("memos").document(memo.id.uuidString).setData(documentData) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
            print("addMemo to Firestore: storeId \(storeId.uuidString), memoId \(memo.id)")
        }
    }

    func updateMemo(storeId: UUID, memo: Memo, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        let documentData: [String: Any] = memo.toDictionary()
        db.collection("users").document(userId).collection("stores").document(storeId.uuidString).collection("memos").document(memo.id.uuidString).updateData(documentData) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    func deleteMemo(storeId: UUID, memoId: UUID, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        db.collection("users").document(userId).collection("stores").document(storeId.uuidString).collection("memos").document(memoId.uuidString).delete() { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
}

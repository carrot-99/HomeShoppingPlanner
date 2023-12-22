//  FirestoreStoreService.swift

import FirebaseFirestore
import FirebaseAuth

class FirestoreStoreService {
    private let db = Firestore.firestore()

    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    func fetchStores(completion: @escaping ([Store], Error?) -> Void) {
        guard let userId = userId else {
            completion([], nil)
            return
        }

        db.collection("users").document(userId).collection("stores").getDocuments { [self] (querySnapshot, error) in
            if let error = error {
                completion([], error)
                return
            }

            var stores: [Store] = []
            let group = DispatchGroup()

            for document in querySnapshot!.documents {
                group.enter()
                let storeId = document.documentID
//                print("fetchStores to firestore\nstoreId:\(storeId)")
                db.collection("users").document(userId).collection("stores").document(storeId).collection("memos").getDocuments { (memoSnapshot, memoError) in
                    var memos: [Memo] = []
                    if let memoSnapshot = memoSnapshot {
//                        print("memo count:\(memoSnapshot.count)")
                        for memoDocument in memoSnapshot.documents {
                            if let memo = Memo(data: memoDocument.data()) {
                                memos.append(memo)
                                print("memoId:\(memo.id)")
                            } else {
                                print("AddMemo failed")
                            }
                        }
                    }
                    let data = document.data()
                    let id = UUID(uuidString: storeId) ?? UUID()
                    let name = data["name"] as? String ?? ""
                    let store = Store(id: id, name: name, memos: memos)
                    stores.append(store)
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(stores, nil)
            }
        }
    }
    
    func fetchStore(storeId: UUID, completion: @escaping (Store?, Error?) -> Void) {
//        print("  fetchStore from firestore")
        guard let userId = userId else {
            completion(nil, nil)
            return
        }

        let storeRef = db.collection("users").document(userId).collection("stores").document(storeId.uuidString)

        storeRef.getDocument { documentSnapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists else {
                completion(nil, nil)
                return
            }

            let data = documentSnapshot.data()
            let name = data?["name"] as? String ?? ""

            storeRef.collection("memos").getDocuments { (memoSnapshot, memoError) in
                var memos: [Memo] = []
                if let memoSnapshot = memoSnapshot {
                    for memoDocument in memoSnapshot.documents {
                        if let memo = Memo(data: memoDocument.data()) {
                            memos.append(memo)
                        }
                    }
                }
                let store = Store(id: storeId, name: name, memos: memos)
                completion(store, nil)
            }
        }
    }

    func addStore(_ store: Store, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        let documentData: [String: Any] = [
            "name": store.name,
            "user_id": userId
        ]

        db.collection("users").document(userId).collection("stores").document(store.id.uuidString).setData(documentData) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    func updateStore(_ store: Store, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        let documentData: [String: Any] = [
            "name": store.name,
            "user_id": userId
        ]

        db.collection("users").document(userId).collection("stores").document(store.id.uuidString).updateData(documentData) { error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    func deleteStore(_ storeId: UUID, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        let storeRef = db.collection("users").document(userId).collection("stores").document(storeId.uuidString)

        deleteMemos(in: storeRef) { success, error in
            if success {
                storeRef.delete() { error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
                }
            } else {
                completion(false, error)
            }
        }
    }

    private func deleteMemos(in storeRef: DocumentReference, completion: @escaping (Bool, Error?) -> Void) {
        storeRef.collection("memos").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }

            guard let querySnapshot = querySnapshot else {
                completion(true, nil)
                return
            }

            let group = DispatchGroup()
            var overallSuccess = true

            for document in querySnapshot.documents {
                group.enter()
                document.reference.delete() { error in
                    if error != nil {
                        overallSuccess = false
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                completion(overallSuccess, nil)
            }
        }
    }
}

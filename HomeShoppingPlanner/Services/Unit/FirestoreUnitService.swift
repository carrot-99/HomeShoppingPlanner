//  FirestoreUnitService.swift

import FirebaseFirestore
import FirebaseAuth

class FirestoreUnitService {
    private let db = Firestore.firestore()

    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    func fetchUnits(completion: @escaping ([String], Error?) -> Void) {
        guard let userId = userId else {
            completion([], nil)
            return
        }

        db.collection("users").document(userId).collection("units").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion([], error)
                return
            }

            let units = querySnapshot?.documents.compactMap { $0.data()["name"] as? String } ?? []
            completion(units, nil)
        }
    }

    func addUnit(_ name: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        db.collection("users").document(userId).collection("units").addDocument(data: ["name": name]) { error in
            completion(error == nil, error)
        }
    }
    
    func updateUnit(oldName: String, newName: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        // Firestore上で指定された古い名前の単位を検索
        let query = db.collection("users").document(userId).collection("units").whereField("name", isEqualTo: oldName)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }

            // ドキュメントを更新
            for document in querySnapshot!.documents {
                document.reference.updateData(["name": newName]) { error in
                    completion(error == nil, error)
                }
            }
        }
    }

    // Firestore上の単位を削除するメソッド
    func deleteUnit(_ name: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        // Firestore上で指定された名前の単位を検索
        let query = db.collection("users").document(userId).collection("units").whereField("name", isEqualTo: name)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(false, error)
                return
            }

            // ドキュメントを削除
            for document in querySnapshot!.documents {
                document.reference.delete { error in
                    completion(error == nil, error)
                }
            }
        }
    }
}

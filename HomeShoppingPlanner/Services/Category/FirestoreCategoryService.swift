//  FirestoreCategoryService.swift

import FirebaseFirestore
import FirebaseAuth

class FirestoreCategoryService {
    private let db = Firestore.firestore()

    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    func fetchCategories(completion: @escaping ([String], Error?) -> Void) {
        guard let userId = userId else {
            completion([], nil)
            return
        }

        db.collection("users").document(userId).collection("categories").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion([], error)
                return
            }

            let categories = querySnapshot?.documents.compactMap { $0.data()["name"] as? String } ?? []
            completion(categories, nil)
        }
    }

    func addCategory(_ name: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        db.collection("users").document(userId).collection("categories").addDocument(data: ["name": name]) { error in
            completion(error == nil, error)
        }
    }
    
    func updateCategory(oldName: String, newName: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        // Firestore上で指定された古い名前のカテゴリを検索
        let query = db.collection("users").document(userId).collection("categories").whereField("name", isEqualTo: oldName)
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

    // Firestore上のカテゴリを削除するメソッド
    func deleteCategory(_ name: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userId else {
            completion(false, nil)
            return
        }

        // Firestore上で指定された名前のカテゴリを検索
        let query = db.collection("users").document(userId).collection("categories").whereField("name", isEqualTo: name)
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

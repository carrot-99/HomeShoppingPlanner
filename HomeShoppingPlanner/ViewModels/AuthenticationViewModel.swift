//  AuthenticationViewModel.swift

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreData

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
            if !isAuthenticated {
                showSignIn = true
            }
        }
    }
    @Published var showSignIn: Bool {
        didSet {
            UserDefaults.standard.set(showSignIn, forKey: "showSignIn")
        }
    }
    @Published var unauthenticatedUser: Bool {
        didSet {
            UserDefaults.standard.set(unauthenticatedUser, forKey: "unauthenticatedUser")
        }
    }
    @Published var showPasswordResetView: Bool = false
    @Published var error: Error?
    @Published var errorMessage: String?
    @Published var isEmailVerified = false
    @Published var showAlert = false
    private var context: NSManagedObjectContext
    private var homeViewModel: HomeViewModel?
    
    init(context: NSManagedObjectContext, homeViewModel: HomeViewModel? = nil) {
        self.context = context
        self.homeViewModel = homeViewModel
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        showSignIn = UserDefaults.standard.bool(forKey: "showSignIn")
        unauthenticatedUser = UserDefaults.standard.bool(forKey: "unauthenticatedUser")
        
        if isAuthenticated {
            refreshEmailVerificationStatus()
        }
    }
    
    private func setError(_ error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.showAlert = true
        }
    }
    
    func clearError() {
        DispatchQueue.main.async {
            self.errorMessage = nil
            self.showAlert = false
        }
    }
    
    // メール認証状態を更新するメソッド
    func refreshEmailVerificationStatus() {
        Auth.auth().currentUser?.reload { [weak self] error in
            if let error = error {
                self?.setError(error)
                return
            }
            DispatchQueue.main.async {
                self?.isEmailVerified = Auth.auth().currentUser?.isEmailVerified ?? false
            }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.setError(error)
                return
            }
            guard let user = result?.user else { return }
            if !user.isEmailVerified {
                self?.errorMessage = "メールアドレスが未確認です。確認メールをチェックしてください。"
                return
            }

            DispatchQueue.main.async {
                self?.isAuthenticated = true
                self?.isEmailVerified = user.isEmailVerified
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.setError(error)
                return
            }
            guard let user = result?.user else { return }

            self?.initializeUserFirestoreData(userId: user.uid)

            user.sendEmailVerification { error in
                if let error = error {
                    self?.setError(error)
                } else {
                    self?.isAuthenticated = true
                    self?.errorMessage = "確認メールを送信しました。メールを確認してアカウントを有効化してください。"
                }
            }
        }
    }
    
    private func initializeUserFirestoreData(userId: String) {
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(userId)

        // 初期カテゴリの追加
        for category in Memo.defaultCategories {
            userDoc.collection("categories").addDocument(data: ["name": category]) { error in
                if let error = error {
                    print("カテゴリの初期化に失敗: \(error)")
                }
            }
        }

        // 初期単位の追加
        for unit in Memo.defaultUnits {
            userDoc.collection("units").addDocument(data: ["name": unit]) { error in
                if let error = error {
                    print("単位の初期化に失敗: \(error)")
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            isAuthenticated = false
        } catch {
            setError(error)
        }
    }
    
    func deleteUser() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        deleteUserFirestoreData(userId: userId) { [weak self] result in
            switch result {
            case .success():
                self?.deleteUserCoreDataData()
                Auth.auth().currentUser?.delete(completion: { error in
                    if let error = error {
                        self?.setError(error)
                    } else {
                        self?.isAuthenticated = false
                        self?.homeViewModel?.resetViewModel()
                    }
                })
            case .failure(let error):
                self?.setError(error)
            }
        }
    }
    
    func deleteUserFirestoreData(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        let userDoc = db.collection("users").document(userId)

        // 'stores' サブコレクション内の各ドキュメント（店舗）を取得
        userDoc.collection("stores").getDocuments { (querySnapshot, error) in
            guard let storeDocuments = querySnapshot?.documents else {
                print("fetch store failed")
                completion(.failure(error ?? NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "サブコレクションの取得に失敗しました"])))
                return
            }
//            print("fetch store success")
            // 各店舗の 'memos' サブコレクションを削除
            for storeDocument in storeDocuments {
                let memosCollection = storeDocument.reference.collection("memos")
//                print("delete memo: \(memosCollection)")
                self.deleteCollection(collection: memosCollection) { error in
                    if let error = error {
                        completion(.failure(error))
                        print("delete memo failed")
                        return
                    } else {
                        print("delete memo success")
                    }
                }

                // 店舗ドキュメント自体を削除
                storeDocument.reference.delete()
            }

            // その他のサブコレクション（'categories', 'units'）を削除
            let otherCollectionsToDelete = ["categories", "units"]
            for collection in otherCollectionsToDelete {
                self.deleteCollection(collection: userDoc.collection(collection)) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                }
            }

            // ユーザードキュメントを削除
            userDoc.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // コレクション内のドキュメントをすべて削除するヘルパーメソッド
    func deleteCollection(collection: CollectionReference, completion: @escaping (Error?) -> Void) {
        collection.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                completion(error)
                return
            }

            for document in documents {
                document.reference.delete()
            }

            completion(nil)
        }
    }


    func deleteUserCoreDataData() {
//        print("deleteUserCoreDataData start")
        let entitiesToDelete = ["CDStore", "CDMemo", "CDCategory", "CDUnit"]
        for entityName in entitiesToDelete {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                print("エンティティ \(entityName) が正常に削除されました")
            } catch {
                print("エンティティ \(entityName) の削除に失敗しました: \(error.localizedDescription)")
            }
        }
        context.refreshAllObjects()
    }
    
    func showSignInView() {
        withAnimation {
            showSignIn = true
            showPasswordResetView = false
        }
//        print("showSignInView:\(showSignIn) \(showPasswordResetView) \(isAuthenticated)")
    }
    
    func sendPasswordReset(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // エラーをユーザーに通知
                print(error.localizedDescription)
            } else {
                // パスワードリセットの指示をユーザーに通知
            }
        }
    }
}

//  AuthenticationManager.swift

import FirebaseAuth

class AuthenticationManager {

    // 現在のユーザーの認証状態をチェックします
    var isAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }

    // ユーザーをログインさせる
    func loginUser(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    // 新しいユーザーを作成する
    func createUser(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    // ユーザーをログアウトさせる
    func logoutUser(completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(true))
        } catch let signOutError as NSError {
            completion(.failure(signOutError))
        }
    }
}

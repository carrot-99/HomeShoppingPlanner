//  SignUpView.swift

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var isFormValid: Bool {
        // メールアドレスが有効か確認
        if !email.isValidEmail() {
            return false
        }

        // パスワードが条件を満たしているか確認
        if !password.isValidPassword() || password != confirmPassword {
            return false
        }

        return true
    }

    var body: some View {
        VStack {
            Text("正確なメールアドレスを入力してください。\nアカウント作成後、メールアドレスの確認が必要です。")
                .font(.caption)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
            
            // メールアドレス入力フィールド
            LabelField("メールアドレス", text: $email, placeholder: "例: example@example.com")

            // パスワード入力フィールド
            LabelField("パスワード（8文字以上、英字と数字を含む）", text: $password, placeholder: "パスワードを入力", isSecure: true)

            // パスワード確認フィールド
            LabelField("パスワード再入力", text: $confirmPassword, placeholder: "パスワードを確認", isSecure: true)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                if validateForm() {
                    authViewModel.signUp(email: email, password: password)
                }
            }) {
                Text("アカウント作成")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!isFormValid)
            .padding(.horizontal)
        }
        .navigationTitle("アカウント作成")
    }
    
    @ViewBuilder
    private func LabelField(_ label: String, text: Binding<String>, placeholder: String, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            if isSecure {
                SecureField(placeholder, text: text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                TextField(placeholder, text: text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
            }
        }
        .padding(.bottom, 5) // ラベルとフィールドの間のパディングを減らす
    }

    private func validateForm() -> Bool {
        if !email.isValidEmail() {
            errorMessage = "無効なメールアドレスです。"
            return false
        }
        if !password.isValidPassword() {
            errorMessage = "パスワードは8文字以上で、英字と数字を含む必要があります。"
            return false
        }
        if password != confirmPassword {
            errorMessage = "パスワードが一致しません。"
            return false
        }
        errorMessage = ""
        return true
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    func isValidPassword() -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$" // 8文字以上、英字と数字を含む
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordTest.evaluate(with: self)
    }
}

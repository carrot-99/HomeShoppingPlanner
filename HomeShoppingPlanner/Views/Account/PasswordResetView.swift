//  PasswordResetView.swift

import SwiftUI

struct PasswordResetView: View {
    @State private var email = ""
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        VStack(spacing: 20) {
            Text("パスワードリセット")
                .font(.title2)

            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            Button("リセットメールを送信") {
                authViewModel.sendPasswordReset(email: email)
            }
            .disabled(!email.isValidEmail())

            Spacer()
        }
        .padding()
        .navigationTitle("パスワードリセット")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//  SignInView.swift

import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    var body: some View {
        VStack {
            // メールアドレス入力フィールド
            LabelField("メールアドレス", text: $email, placeholder: "メールアドレスを入力")

            // パスワード入力フィールド
            LabelField("パスワード", text: $password, placeholder: "パスワードを入力", isSecure: true)

            Button(action: {
                authViewModel.signIn(email: email, password: password)
            }) {
                Text("ログイン")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            NavigationLink("アカウントを作成", destination: SignUpView().environmentObject(authViewModel))
                .padding()
            
            Button("パスワードを忘れた場合") {
                withAnimation {
                    authViewModel.showPasswordResetView = true
                }
            }
            .padding()

            NavigationLink(destination: PasswordResetView().environmentObject(authViewModel), isActive: $authViewModel.showPasswordResetView) {
                EmptyView()
            }
            Button("アカウントを作成しない") {
                authViewModel.unauthenticatedUser = true
                authViewModel.showSignIn = false
                print("アカウントなし:\(authViewModel.unauthenticatedUser) \(authViewModel.showSignIn) \(authViewModel.isAuthenticated)")
            }
            .padding()
        }
        .navigationTitle("ログイン")
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
        .padding(.bottom, 5)
    }
}

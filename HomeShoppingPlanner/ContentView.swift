// ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel: AuthenticationViewModel
    @StateObject var homeViewModel: HomeViewModel
    @State private var hasAgreedToTerms = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")
    @State private var isShowingTerms = true
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(context: context))
        _authViewModel = StateObject(wrappedValue: AuthenticationViewModel(context: context))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if hasAgreedToTerms {
                NavigationView {
                    if authViewModel.isAuthenticated {
                        HomeView(authViewModel: authViewModel, viewModel: homeViewModel)
                            .environmentObject(authViewModel)
                            .environmentObject(homeViewModel)
                    } else {
                        if authViewModel.showSignIn {
                            SignInView()
                                .environmentObject(authViewModel)
                        } else if authViewModel.showPasswordResetView {
                            PasswordResetView()
                                .environmentObject(authViewModel)
                        } else if authViewModel.unauthenticatedUser {
                            HomeView(authViewModel: authViewModel, viewModel: homeViewModel)
                                .environmentObject(authViewModel)
                                .environmentObject(homeViewModel)
                        } else {
                            SignInView()
                                .environmentObject(authViewModel)
                        }
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .alert(isPresented: $authViewModel.showAlert) {
                    Alert(
                        title: Text("エラー"),
                        message: Text(authViewModel.errorMessage ?? "不明なエラーが発生しました"),
                        dismissButton: .default(Text("OK"), action: {
                            authViewModel.clearError()
                        })
                    )
                }
                
                AdMobBannerView()
                    .frame(width: UIScreen.main.bounds.width, height: 50)
                    .background(Color.gray.opacity(0.1))
            } else {
                TermsAndPrivacyAgreementView(isShowingTerms: $isShowingTerms, hasAgreedToTerms: $hasAgreedToTerms)
            }
        }
    }
}

//  SideMenuView.swift

import Foundation
import SwiftUI

struct SideMenuView: View {
    @Binding var isMenuOpen: Bool
    @State private var currentView: AnyView?
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        ZStack {
            // タップして閉じる機能
            GeometryReader { _ in
                EmptyView()
            }
            .background(Color.black.opacity(0.5))
            .opacity(isMenuOpen ? 1 : 0)
            .onTapGesture {
                withAnimation {
                    isMenuOpen = false
                }
            }

            VStack {
                Spacer()
                
                Button(action: {
                    currentView = AnyView(HomeView(authViewModel: authViewModel, viewModel: viewModel)
                        .environmentObject(authViewModel)
                        .environmentObject(viewModel))
                    isMenuOpen = false
                }) {
                    Text("ホーム")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
                .padding()
                
                NavigationLink(destination: UnitListView(viewModel: viewModel)) {
                    Text("単位設定")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
                .padding()

                NavigationLink(destination: CategoryListView(viewModel: viewModel)) {
                    Text("カテゴリ設定")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
                .padding()
                
                NavigationLink(destination: TermsView()) {
                    Text("利用規約")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
                .padding()
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("プライバシーポリシー")
                        .foregroundColor(.blue)
                        .font(.headline)
                }
                .padding()
                
                Group {
                    if authViewModel.isAuthenticated {
                        Button(action: {
                            authViewModel.signOut()
                            isMenuOpen = false
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .imageScale(.large)
                                    .foregroundColor(.blue)
                                Text("ログアウト")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                            }
                        }
                        .padding()
                        
                        Button(action: {
                            authViewModel.deleteUser()
                            isMenuOpen = false
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                    .imageScale(.large)
                                    .foregroundColor(.red)
                                Text("アカウント削除")
                                    .foregroundColor(.red)
                                    .font(.headline)
                            }
                        }
                        .padding()
                    } else {
                        Button(action: {
                            authViewModel.showSignInView()
                            isMenuOpen = false
                        }) {
                            Text("ログイン/アカウント作成")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                        .padding()
                    }
                    
                    Button(action: {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }) {
                        Text("閉じる")
                            .foregroundColor(.blue)
                            .font(.headline)
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .frame(width: 250)
            .background(Color.gray)
            .edgesIgnoringSafeArea(.all)
            .offset(x: isMenuOpen ? 0 : -250)
        }
    }
}

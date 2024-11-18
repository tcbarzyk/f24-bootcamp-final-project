import SwiftUI

extension Color {
    static let textColor = Color("TextColor")
}

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @EnvironmentObject var appState: AppState
    
    @Binding var path: NavigationPath
    
    var body: some View {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.main.opacity(1)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Login")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 70)
                    
                    VStack(spacing: 16) {
                        CustomTextField(placeholder: "Username", text: $viewModel.username)
                        CustomTextField(placeholder: "Password", text: $viewModel.password, isSecure: true)
                    }
                    .padding(20)
                    
                    // Login Button
                    Button(action: {
                        Task {
                            await viewModel.login()
                            if (viewModel.loginSuccess) {
                                appState.isLoggedIn = true
                                path = NavigationPath()
                            }
                        }
                    }) {
                        Text("Login")
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)
                    .disabled(viewModel.currentlyLoggingIn)
                    /*
                    Button("Back to root", action: {
                        path = NavigationPath()
                    })*/
                    
                    if viewModel.currentlyLoggingIn {
                        ProgressView("Processing...")
                        .padding()
                    }
                    
                    if let status = viewModel.loginStatus {
                        Text(status)
                        .padding()
                    }
                    Spacer()
                    
                    // Sign-up Option
                    VStack {
                        Text("Don't have an account?")
                            .foregroundColor(.white)
                        NavigationLink (
                            destination: { SignupView(path: $path) },
                            label: {
                                Text("Sign up")
                                .foregroundColor(.accent)
                            }
                        )
                    }
                    .padding(.bottom, 40)
                }
                .padding(.horizontal, 20)
            }
            .accentColor(.textColor)
        }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.5))
                .frame(height: 50)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .padding(.horizontal, 15)
                    .foregroundColor(.main)
            } else {
                TextField(placeholder, text: $text)
                    .padding(.horizontal, 15)
                    .foregroundColor(.main)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
    }
}

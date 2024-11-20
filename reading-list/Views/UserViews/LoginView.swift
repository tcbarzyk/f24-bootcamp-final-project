import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    @EnvironmentObject var appState: AppState
    
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 60)
                
                VStack(spacing: 16) {
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            Task {
                                if (!viewModel.currentlyLoggingIn) {
                                    await viewModel.login()
                                    if (viewModel.loginSuccess) {
                                        appState.isLoggedIn = true
                                        path = NavigationPath()
                                    }
                                }
                            }
                        }
                }
                .padding(20)
                
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
                        .font(.title2)
                        .bold()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.currentlyLoggingIn)
                
                if viewModel.currentlyLoggingIn {
                    ProgressView("Processing...")
                        .padding()
                }
                
                if let status = viewModel.loginStatus {
                    Text(status)
                        .padding()
                }
                
                Spacer()
                
                VStack {
                    Text("Don't have an account?")
                    NavigationLink (
                        destination: { SignupView(path: $path) },
                        label: {
                            Text("Sign up")
                        }
                    )
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
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
            } else {
                TextField(placeholder, text: $text)
                    .padding(.horizontal, 15)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

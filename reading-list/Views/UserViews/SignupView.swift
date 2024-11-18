import SwiftUI

struct SignupView: View {
    @StateObject var viewModel = SignupViewModel()
    @State private var navigateToLogin: Bool = false
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.main.opacity(1)]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Make Account")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.textColor)
                    .padding(.top, 60)
                
                VStack(spacing: 16) {
                    CustomTextField(placeholder: "Username", text: $viewModel.username)
                    CustomTextField(placeholder: "Email", text: $viewModel.email)
                    CustomTextField(placeholder: "Password", text: $viewModel.password, isSecure: true)
                }
                .padding(20)
                
                // Signup Button
                Button(action: {
                    Task {
                        await viewModel.signup()
                    }
                }) {
                    Text("Sign Up")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .disabled(viewModel.currentlySigningUp)
                
                if viewModel.currentlySigningUp {
                    ProgressView("Processing...")
                    .padding()
                }
                
                if let status = viewModel.signupStatus {
                    Text(status)
                        .padding()
                        .foregroundColor(.textColor)
                }
                
                Spacer()
                
                // Sign-up Option
                VStack {
                    Text("Already have an account?")
                        .foregroundColor(.white)
                    NavigationLink (
                        destination: { LoginView(path: $path) },
                        label: {
                            Text("Login")
                            .foregroundColor(.accent)
                        }
                    )
                    .foregroundColor(.accent)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
            
            NavigationLink(value: viewModel.success) { EmptyView() }
        }
        .alert("Signup Successful!", isPresented: $viewModel.success) {
            Button("Login") {
                navigateToLogin = true
            }
        }
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView(path: $path)
        }
        .accentColor(.main)
    }
}

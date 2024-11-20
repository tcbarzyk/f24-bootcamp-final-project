import SwiftUI

struct SignupView: View {
    @StateObject var viewModel = SignupViewModel()
    @State private var navigateToLogin: Bool = false
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Make Account")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.top, 60)
                
                VStack(spacing: 16) {
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            Task {
                                if (!viewModel.currentlySigningUp) {
                                    await viewModel.signup()
                                }
                            }
                        }
                }
                .padding(20)
                
                Button(action: {
                    Task {
                        await viewModel.signup()
                    }
                }) {
                    Text("Sign Up")
                        .font(.title2)
                        .bold()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.currentlySigningUp)
                
                if viewModel.currentlySigningUp {
                    ProgressView("Processing...")
                        .padding()
                }
                
                if let status = viewModel.signupStatus {
                    Text(status)
                        .padding()
                }
                
                Spacer()
                
                VStack {
                    Text("Already have an account?")
                    NavigationLink (
                        destination: { LoginView(path: $path) },
                        label: {
                            Text("Login")
                        }
                    )
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
    }
}

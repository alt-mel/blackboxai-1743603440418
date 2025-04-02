import SwiftUI

struct AuthenticationView: View {
    @State private var isShowingSignUp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.opacity(0.9).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Logo
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("SleepTracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Track and improve your sleep")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Auth Buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: SignInView()) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(15)
                        }
                        
                        NavigationLink(destination: SignUpView()) {
                            Text("Create Account")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct SignInView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Text("Welcome Back")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        CustomTextField(
                            text: $viewModel.email,
                            placeholder: "Email",
                            icon: "envelope.fill"
                        )
                        
                        CustomSecureField(
                            text: $viewModel.password,
                            placeholder: "Password",
                            icon: "lock.fill"
                        )
                    }
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: signIn) {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(viewModel.isLoading)
                    
                    Button("Forgot Password?") {
                        // Handle forgot password
                    }
                    .foregroundColor(.gray)
                }
                .padding()
            }
        }
        .navigationBarTitle("Sign In", displayMode: .inline)
    }
    
    private func signIn() {
        Task {
            await viewModel.signIn()
        }
    }
}

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 20) {
                        CustomTextField(
                            text: $viewModel.name,
                            placeholder: "Name",
                            icon: "person.fill"
                        )
                        
                        CustomTextField(
                            text: $viewModel.email,
                            placeholder: "Email",
                            icon: "envelope.fill"
                        )
                        
                        CustomSecureField(
                            text: $viewModel.password,
                            placeholder: "Password",
                            icon: "lock.fill"
                        )
                        
                        CustomSecureField(
                            text: $viewModel.confirmPassword,
                            placeholder: "Confirm Password",
                            icon: "lock.fill"
                        )
                    }
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: signUp) {
                        Group {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create Account")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding()
            }
        }
        .navigationBarTitle("Sign Up", displayMode: .inline)
    }
    
    private func signUp() {
        Task {
            await viewModel.signUp()
        }
    }
}

struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    @State private var isSecured = true
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            
            if isSecured {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
            
            Button(action: { isSecured.toggle() }) {
                Image(systemName: isSecured ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var name = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    func signIn() async {
        guard validate() else { return }
        
        await MainActor.run { isLoading = true }
        
        do {
            try await UserManager.shared.signIn(email: email, password: password)
            await MainActor.run {
                isLoading = false
                errorMessage = ""
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func signUp() async {
        guard validateSignUp() else { return }
        
        await MainActor.run { isLoading = true }
        
        do {
            try await UserManager.shared.signUp(email: email, password: password, name: name)
            await MainActor.run {
                isLoading = false
                errorMessage = ""
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    private func validate() -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return false
        }
        
        return true
    }
    
    private func validateSignUp() -> Bool {
        guard !name.isEmpty else {
            errorMessage = "Please enter your name"
            return false
        }
        
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return false
        }
        
        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return false
        }
        
        return true
    }
}

#Preview {
    AuthenticationView()
}
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoginSuccessful = false
    @State private var navigateToSignupView = false
    @State private var userUID: String? = nil
    @State private var navigateToMyQRCodeView = false

    var body: some View {
        NavigationView {
            ZStack {
                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Image("Autoshopicon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .offset(y: 0)

                    Text("用戶登入")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 30)

                    VStack(spacing: 15) {
                        TextField("輸入電郵", text: $email)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white))
                            .foregroundColor(Color.black)
                            .font(.body)
                            .autocapitalization(.none)
                            .colorScheme(.light) // Ensure the placeholder color is applied in both light and dark modes

                        SecureField("輸入密碼", text: $password)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white))
                            .foregroundColor(Color.black)
                            .font(.body)
                            .autocapitalization(.none)
                            .colorScheme(.light) // Ensure the placeholder color is applied in both light and dark modes
                    }

                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)

                    Button(action: {
                        if isValidInput() {
                            authenticateUser()
                        } else {
                            errorMessage = "輸入無效。請檢查您的資訊。"
                        }
                    }) {
                        Text("立即登入")
                            .font(.headline)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(SharedButtonStyle())

                    Button(action: {
                        navigateToSignupView = true
                    }) {
                        Text("立即登記")
                            .font(.headline)
                            .padding(.vertical, 4)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(WhiteButtonStyle())
                    .padding(.top, 0)

                    HStack {
                        Text("註冊即表示您同意我們的")
                            .foregroundColor(Color.black)

                        Link("隱私政策", destination: URL(string: "https://www.everything-intelligence.com/privacy/")!)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)

                    HStack {
                        NavigationLink(
                            destination: MyqrcodeView(uid: userUID ?? ""),
                            isActive: $navigateToMyQRCodeView
                        ) {
                            EmptyView()
                        }
                        .hidden()

                        NavigationLink(
                            destination: Signup(),
                            isActive: $navigateToSignupView
                        ) {
                            Text("還沒有帳戶？立即登記")
                                .foregroundColor(.blue)
                                .underline()
                        }
                        .padding(.top, 0)
                    }
                }
                .padding()
                .offset(y: 10) // Vertical offset of 10 pixels
            }
        }
    }

    private func isValidInput() -> Bool {
        return !email.isEmpty && !password.isEmpty
    }

    private func authenticateUser() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "錯誤：\(error.localizedDescription)"
                print("Authentication failed with error: \(error.localizedDescription)")
            } else {
                if let uid = authResult?.user.uid {
                    print("Authentication successful. User UID: \(uid)")
                    userUID = uid
                    isLoginSuccessful = true
                    navigateToMyQRCodeView = true // Set this to true to trigger navigation
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreImage

struct Signup: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var uid: String?
    @State private var qrCode: String?
    @State private var navigateToQRCodeView = false
    @State private var navigateToLoginView = false

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

                    Text("用戶登記")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.bottom, 30)

                    VStack(spacing: 15) {
                        TextField("輸入電郵", text: $email)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white))
                            .foregroundColor(.black) // Set the color for the inserted text
                            .font(.body)
                            .autocapitalization(.none)
                            .colorScheme(.light) // Ensure the placeholder color is applied in both light and dark modes
                       
                        SecureField("輸入密碼", text: $password)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.white))
                            .foregroundColor(.black) // Set the color for the inserted text
                            .font(.body)
                            .autocapitalization(.none)
                            .colorScheme(.light) // Ensure the placeholder color is applied in both light and dark modes
                    }

                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 0)

                    VStack(spacing: 10) {
                        Button(action: {
                            if isValidInput() {
                                signUpWithFirebase()
                            } else {
                                errorMessage = "Invalid input. Please check your information."
                            }
                        }) {
                            Text("立即登記")
                                .font(.headline)
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(!isValidInput())

                        NavigationLink(destination: LoginView(), isActive: $navigateToLoginView) {
                            EmptyView()
                        }

                        Button(action: {
                            navigateToLoginView = true
                        }) {
                            Text("立即登入")
                                .font(.headline)
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 10)

                    HStack {
                        Text("註冊即表示您同意我們的")
                               .foregroundColor(Color.black)
                             
                        NavigationLink(
                            destination: MyqrcodeView(uid: uid),
                            isActive: $navigateToQRCodeView
                        ) {
                            EmptyView()
                        }
                        .hidden()

                        Link("隱私政策", destination: URL(string: "https://www.everything-intelligence.com/privacy/")!)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)

                    Text("已有戶口？立即登入")
                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            navigateToLoginView = true
                        }
                        .padding(.top, 10)
                }
                .padding()
            }
            .onAppear {
                // Additional setup or actions when the view appears
            }
        }
    }

    private func isValidInput() -> Bool {
        return !email.isEmpty && !password.isEmpty
    }

    private func signUpWithFirebase() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "Error: \(error.localizedDescription)"
            } else {
                if let uid = authResult?.user.uid {
                    createFirestoreUser(uid: uid)
                    self.uid = uid
                    qrCode = generateQRCode(withUID: uid)
                    navigateToQRCodeView = true
                }
            }
        }
    }

    private func createFirestoreUser(uid: String) {
        let db = Firestore.firestore()
        let usersCollection = db.collection("Users")

        let userData: [String: Any] = [
            "email": email,
            "qrCode": uid,
            "userId": uid,
            "uid": uid,
            "storeId": "OSP024"
        ]

        usersCollection.document(uid).setData(userData) { error in
            if let error = error {
                print("Error creating user document: \(error.localizedDescription)")
            } else {
                print("User document created successfully")
            }
        }
    }

    private func generateQRCode(withUID uid: String) -> String {
        let combinedData = "\(uid)".data(using: .utf8)

        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return ""
        }

        qrFilter.setValue(combinedData, forKey: "inputMessage")

        guard let qrOutputImage = qrFilter.outputImage else {
            return ""
        }

        let context = CIContext()
        guard let cgImage = context.createCGImage(qrOutputImage, from: qrOutputImage.extent) else {
            return ""
        }

        let uiImage = UIImage(cgImage: cgImage)

        if let imageData = uiImage.pngData() {
            return imageData.base64EncodedString()
        }

        return ""
    }
    
    
}

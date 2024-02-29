import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct MyqrcodeView: View {
    let uid: String?
    @State private var isPaymentSetupNoticePresented = false
    @State private var isActivePaymentView = false
    @State private var isActiveCartView = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                VStack {
                    Text("我的QR碼")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding(.top, 20)
                        .fontWeight(.bold)
                    
                    ZStack(alignment: .center) {
                        generateQRCode()
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200, alignment: .center)
                            .padding(.trailing, 00)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Text("掃碼進入AutoShop")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                        .fontWeight(.bold)
                }
                .padding()
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        // Handle QR Code button action
                    }) {
                        VStack {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.title)
                                .foregroundColor(.blue)
                            Text("QR Code")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .buttonStyle(SharedButtonStyle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isActivePaymentView = true
                        isActiveCartView = false
                    }) {
                        VStack {
                            Image(systemName: "creditcard.fill")
                                .font(.title)
                                .foregroundColor(isActivePaymentView ? .blue : .gray)
                            Text("付款設定")
                                .font(.footnote)
                                .foregroundColor(isActivePaymentView ? .blue : .gray)
                        }
                        .padding()
                        .buttonStyle(SharedButtonStyle())
                    }
                    .background(NavigationLink("", destination: PaymentView(), isActive: $isActivePaymentView))
                    
                    Spacer()
                    
                    Button(action: {
                        isActiveCartView = true
                        isActivePaymentView = false
                    }) {
                        VStack {
                            Image(systemName: "cart.fill")
                                .font(.title)
                                .foregroundColor(isActiveCartView ? .blue : .gray)
                            Text("購物車")
                                .font(.footnote)
                                .foregroundColor(isActiveCartView ? .blue : .gray)
                        }
                        .padding()
                        .buttonStyle(SharedButtonStyle())
                    }
                    .background(NavigationLink("", destination: CartView(), isActive: $isActiveCartView))
                    
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .sheet(isPresented: $isPaymentSetupNoticePresented) {
                PaymentSetupNoticeView()
            }
            .navigationBarHidden(true)
        }
    }
    
    func generateQRCode() -> Image {
        guard let uid = self.uid, let data = uid.data(using: .utf8) else {
            return Image(systemName: "xmark.circle")
        }

        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else {
            return Image(systemName: "xmark.circle")
        }

        qrFilter.setValue(data, forKey: "inputMessage")

        guard let qrOutputImage = qrFilter.outputImage else {
            return Image(systemName: "xmark.circle")
        }

        let context = CIContext()
        guard let cgImage = context.createCGImage(qrOutputImage, from: qrOutputImage.extent) else {
            return Image(systemName: "xmark.circle")
        }

        let uiImage = UIImage(cgImage: cgImage)

        return Image(uiImage: uiImage)
            .resizable()
            .interpolation(.none)
    }




    
    struct User {
        let uid: String
        // Other user-related properties
    }
    
    class UserManager {
        static let shared = UserManager()
        
        private var user: User?
        
        private init() {}
        
        func setUser(_ user: User) {
            self.user = user
        }
        
        func getUser() -> User? {
            return user
        }
    }
}

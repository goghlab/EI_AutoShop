import SwiftUI

struct PaymentSuccessView: View {
    @State private var isQRCodeVisible = true

    var body: some View {
        VStack {
            Text("成功付款, 感謝惠顧!")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            Text("請掃此QR碼離開本店")
                .font(.title3)
                .fontWeight(.bold)
                .padding()

            if isQRCodeVisible {
                // Display QR code here
                generateQRCode()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .onAppear {
                        // Automatically hide QR code after 10 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            isQRCodeVisible = false
                        }
                    }
            } else {
                // Display message after QR code disappears
                Text("請聯繫我們的工作人員以離開本店")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding()
            }

            Spacer()
        }
    }

    // Function to generate QR code (similar to your previous implementation)
    func generateQRCode() -> Image {
        // Implement your QR code generation logic here
        // ...

        return Image(systemName: "qrcode")
    }
}

struct PaymentSuccessView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentSuccessView()
    }
}

import SwiftUI

struct PaymentSetupNoticeView: View {
    @State private var isActivePaymentView = false

    var body: some View {
        VStack {
            Button(action: {
                isActivePaymentView.toggle()
            }) {
                VStack {
                    Image(systemName: "creditcard.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding(.bottom, 10)

                    Text("設定付款方式")
                        .font(.title)
                        .padding(.bottom, 10)

                    Text("在進入商店之前，請先設定您的付款方式。")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .background(NavigationLink("", destination: PaymentView(), isActive: $isActivePaymentView))
        }
    }
}

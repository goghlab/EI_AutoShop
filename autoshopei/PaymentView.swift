import SwiftUI

struct PaymentView: View {
    let paymentOptions = [
        "Credit Card",
        "AliPay",
        "WeChat Pay",
        "PayPal",
        "Google Pay",
        "Apple Pay"
    ]

    var body: some View {
        VStack {
            Text("付款設定")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 20) {
                ForEach(paymentOptions, id: \.self) { option in
                    PaymentOptionView(paymentOption: option)
                }
            }
            .padding()

            Spacer()
        }
    }
}

struct PaymentOptionView: View {
    var paymentOption: String

    var body: some View {
        VStack {
            Image(systemName: "creditcard.fill") // You can use appropriate icons
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .padding()

            Text(paymentOption)
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView()
    }
}

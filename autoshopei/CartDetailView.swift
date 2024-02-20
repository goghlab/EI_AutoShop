import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CartDetailView: View {
    var cartItem: CartItem
    var cartItemViewModel: CartItemViewModel

    @State private var isPaymentSuccessPresented = false

    var body: some View {
        VStack {
            Text("購物車詳情")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.black) // Set title color to black

            Text("購物車ID: \(cartItem.id)")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .foregroundColor(.black) // Set text color to black

            ForEach(cartItem.items) { itemDetail in
                VStack(alignment: .leading, spacing: 8) {
                    Text("商品ID: \(itemDetail.upc)")
                        .font(.subheadline)
                        .foregroundColor(.black) // Set text color to black
                    Text("數量: \(itemDetail.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.black) // Set text color to black
                    Text("售價: \(String(format: "%.2f", itemDetail.price))")
                        .font(.subheadline)
                        .foregroundColor(.black) // Set text color to black
                    Text("小計: \(String(format: "%.2f", itemDetail.subtotal))")
                        .font(.subheadline)
                        .foregroundColor(.black) // Set text color to black
                    Divider()
                }
                .padding()
            }

            if cartItemViewModel.arePricesLoaded {
                Text("總計: $\(String(format: "%.2f", cartItem.items.reduce(0.0) { $0 + $1.subtotal }))")
                    .foregroundColor(.black) // Set text color to black
                    .font(.subheadline)
                    .padding(.top, 10)
            } else {
                Text("Total: 計算中...")
                    .foregroundColor(.black) // Set text color to black
                    .font(.subheadline)
                    .padding(.top, 10)
            }

            // Pay Now Button
            NavigationLink(destination: PaymentSuccessView(), isActive: $isPaymentSuccessPresented) {
                Button(action: {
                    // Add your logic to handle the "Pay Now" action
                    // This could include navigating to a payment screen or triggering a payment process
                    // Example: cartItemViewModel.handlePayNow()
                    isPaymentSuccessPresented = true
                }) {
                    Text("立即付款")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .background(Color.white) // Set background color to white
    }
}

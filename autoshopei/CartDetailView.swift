import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CartDetailView: View {
    var cartItem: CartItem
    var cartItemViewModel: CartItemViewModel
    
    @EnvironmentObject var paymentViewModel: PaymentViewModel
    @State private var isPaymentSuccessPresented = false

    var body: some View {
        VStack {
            Text("購物車詳情")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.black)

            Text("購物車ID: \(cartItem.id)")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .foregroundColor(.black)

            ForEach(cartItem.items) { itemDetail in
                VStack(alignment: .leading, spacing: 8) {
                    Text("商品ID: \(itemDetail.upc)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Text("數量: \(itemDetail.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Text("售價: \(String(format: "%.2f", itemDetail.price))")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Text("小計: \(String(format: "%.2f", itemDetail.subtotal))")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    Divider()
                }
                .padding()
            }

            if cartItemViewModel.arePricesLoaded {
                Text("總計: $\(paymentViewModel.totalAmount)")
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .padding(.top, 10)
                    .onAppear {
                        paymentViewModel.updateTotalAmount(cartItems: cartItem.items)
                    }
            } else {
                Text("Total: 計算中...")
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .padding(.top, 10)
            }

            // Pay Now Button
            Button(action: {
                paymentViewModel.initiatePayment(cartItems: cartItem.items)
            }) {
                Text("立即付款")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

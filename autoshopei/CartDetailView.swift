import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CartDetailView: View {
    var cartItem: CartItem
    var cartItemViewModel: CartItemViewModel

    var body: some View {
        VStack {
            Text("Cart Detail")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("Cart ID: \(cartItem.id)")
                .font(.headline)
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .foregroundColor(.black) // Set text color to black

            ForEach(cartItem.items) { itemDetail in
                VStack(alignment: .leading, spacing: 8) {
                    Text("UPC: \(itemDetail.upc)")
                        .font(.subheadline)
                    Text("Quantity: \(itemDetail.quantity)")
                        .font(.subheadline)
                    Text("Price: \(String(format: "%.2f", itemDetail.price))")
                        .font(.subheadline)
                    Text("Subtotal: \(String(format: "%.2f", itemDetail.subtotal))")
                        .font(.subheadline)
                    Divider()
                }
                .padding()
            }

            if cartItemViewModel.arePricesLoaded {
                Text("Total: $\(String(format: "%.2f", cartItem.items.reduce(0.0) { $0 + $1.subtotal }))")
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
            Button(action: {
                // Add your logic to handle the "Pay Now" action
                // This could include navigating to a payment screen or triggering a payment process
                // Example: cartItemViewModel.handlePayNow()
            }) {
                Text("Pay Now")
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
        .background(Color.white) // Set background color to white
    }
}

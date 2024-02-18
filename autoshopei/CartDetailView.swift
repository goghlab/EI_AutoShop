import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CartDetailView: View {
    var cartItem: CartItem

    @State private var prices: [String: Double] = [:]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Details")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            ForEach(cartItem.items) { itemDetail in
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("貨品ID: \(itemDetail.upc)")
                            .font(.headline)
                            .fontWeight(.bold)

                        Text("數量: \(itemDetail.quantity)")
                            .foregroundColor(.gray)

                        // Place PriceView here to ensure proper nesting
                        PriceView(upc: itemDetail.upc)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
                .padding(.vertical, 4)
            }

            Spacer()
        }
        .padding()
        .navigationBarTitle("Cart Details", displayMode: .inline)
    }
}

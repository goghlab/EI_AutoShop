import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PaymentView: View {
    @ObservedObject private var cartItemViewModel = CartItemViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("已付款購物車")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.black) // Set title color to black

                List(cartItemViewModel.cartItems.filter { $0.paid == true }) { item in // Modify the filter condition here
                    PaymentCartItemView(cartItem: item)
                        .background(Color.white)
                }
                .listStyle(InsetListStyle())
                .padding()
                .background(Color.white) // Set background color to white for the entire list

                Spacer()
            }
            .onAppear {
                // Fetch paid cart transactions for the current user
                self.cartItemViewModel.fetchCartTransactionsForCurrentUser()
            }
            .background(Color.white) // Set background color to white for the entire view
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.black) // Set title color to black
        }
    }
}

struct PaymentCartItemView: View {
    var cartItem: CartItem

    var body: some View {
        VStack(alignment: .leading) {
            Text("購物車ID: \(cartItem.id)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black) // Set text color to black
            
            ForEach(cartItem.items) { item in
                PaymentCartItemDetailView(cartItemDetail: item)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct PaymentCartItemDetailView: View {
    var cartItemDetail: CartItemDetail

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("UPC: \(cartItemDetail.upc)")
                Text("Quantity: \(cartItemDetail.quantity)")
                Text("Price: \(cartItemDetail.price)")
            }
            Spacer()
            Text("Subtotal: \(cartItemDetail.subtotal)")
        }
        .padding(.horizontal)
    }
}

struct PaymentView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentView()
    }
}

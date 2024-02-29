import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CartItemDetail: Identifiable {
    let id = UUID()
    let upc: String
    let quantity: Int
    var price: Double

    var subtotal: Double {
        return Double(quantity) * price
    }
}

struct CartItem: Identifiable {
    let id: String
    var items: [CartItemDetail]
    // Add other properties based on your document structure
}

class CartItemViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var arePricesLoaded: Bool = false

    func fetchCartTransactionsForCurrentUser() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            // Handle the case when the user is not logged in
            return
        }

        let db = Firestore.firestore()

        db.collection("Users").document(currentUserUID).collection("cartTransactions")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }

                let cartItems = documents.map { document in
                    let items = (document["items"] as? [[String: Any]] ?? []).map { itemDict in
                        CartItemDetail(
                            upc: itemDict["upc"] as? String ?? "",
                            quantity: itemDict["qty"] as? Int ?? 0,
                            price: itemDict["price"] as? Double ?? 0.0
                        )
                    }

                    return CartItem(
                        id: document.documentID,
                        items: items
                        // Add other properties based on your document structure
                    )
                }

                self.cartItems = cartItems
                self.arePricesLoaded = false

                self.fetchPricesForItems()
            }
    }

    func fetchPricesForItems() {
        for item in cartItems {
            for itemDetail in item.items {
                fetchPriceForUPC(itemDetail.upc) { fetchedPrice in
                    if let fetchedPrice = fetchedPrice {
                        if let cartItemIndex = self.cartItems.firstIndex(where: { $0.id == item.id }),
                           let itemIndex = self.cartItems[cartItemIndex].items.firstIndex(where: { $0.upc == itemDetail.upc }) {
                            self.cartItems[cartItemIndex].items[itemIndex].price = fetchedPrice
                        }
                    }

                    self.checkIfAllPricesLoaded()
                }
            }
        }
    }

    func checkIfAllPricesLoaded() {
        let allPricesLoaded = cartItems.allSatisfy { $0.items.allSatisfy { $0.price != 0.0 } }
        if allPricesLoaded {
            self.arePricesLoaded = true
        }
    }
}

struct CartView: View {
    @ObservedObject private var cartItemViewModel = CartItemViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("購物車")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .foregroundColor(.black) // Set title color to black

                List(cartItemViewModel.cartItems) { item in
                    CartItemView(cartItem: item, cartItemViewModel: cartItemViewModel)
                        .background(Color.white) // Set background color to white for each row
                }
                .listStyle(InsetListStyle())
                .padding()
                .background(Color.white) // Set background color to white for the entire list

                Spacer()
            }
            .onAppear {
                cartItemViewModel.fetchCartTransactionsForCurrentUser()
            }
            .background(Color.white) // Set background color to white for the entire view
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.black) // Set title color to black
        }
    }
}

struct CartItemView: View {
    var cartItem: CartItem
    @ObservedObject var cartItemViewModel: CartItemViewModel

    var body: some View {
        NavigationLink(destination: CartDetailView(cartItem: cartItem, cartItemViewModel: cartItemViewModel)) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("購物車ID: \(cartItem.id)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black) // Set text color to black
                }
                Spacer()
            }
            .padding(8)
            .background(Color.white) // Set background color to white
            .cornerRadius(10)
            .shadow(radius: 3)
            .padding(.vertical, 4)
        }
    }
}

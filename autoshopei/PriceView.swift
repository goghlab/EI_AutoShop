import SwiftUI
import FirebaseFirestore
import FirebaseAuth
struct PriceView: View {
    var upc: String
    @State private var price: Double?
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("售價:")
                .font(.headline)
                .fontWeight(.bold)
            
            if isLoading {
                Text("等待中...") // Display loading state
                    .foregroundColor(.gray)
            } else {
                if let price = price {
                    Text("$\(String(format: "%.2f", price))") // Display formatted price
                        .foregroundColor(.gray)
                } else {
                    Text("N/A")
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            // Fetch price for UPC when the view appears
            isLoading = true
            fetchPriceForUPC(upc) { fetchedPrice in
                if let fetchedPrice = fetchedPrice {
                    // Convert the string to a number
                    if let priceValue = Double(fetchedPrice) {
                        // Update the @State variable to trigger a UI update
                        self.price = priceValue
                    }
                }
                isLoading = false
            }
        }
    }
}

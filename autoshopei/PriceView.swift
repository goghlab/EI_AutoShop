import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct PriceView: View {
    var upc: String
    @State private var price: Double? // Use @State to trigger a view update

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("售價:")
                .font(.headline)
                .fontWeight(.bold)

            if let price = price {
                Text("$\(String(format: "%.2f", price))")
                    .foregroundColor(.gray)
            } else {
                Text("等待中...")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            fetchPriceForUPC(upc) { fetchedPrice in
                // Update the @State property to trigger a view update
                self.price = fetchedPrice
            }
        }
    }
}

func fetchPriceForUPC(_ upc: String, completion: @escaping (Double?) -> Void) {
    let db = Firestore.firestore()

    let priceQuery = db.collection("852items").document(upc)

    priceQuery.getDocument { document, error in
        if let error = error {
            print("Error fetching document for \(upc): \(error.localizedDescription)")
            completion(nil) // Handle the error by passing nil
            return
        }

        guard let document = document, document.exists else {
            print("Document for \(upc) does not exist")
            completion(nil) // Handle the case where the document does not exist
            return
        }

        if let fetchedPrice = document["price"] as? Double {
            print("Fetched price for \(upc): \(fetchedPrice)")
            completion(fetchedPrice)
        } else {
            print("Invalid price format for \(upc)")
            completion(nil) // Handle the case where the price format is invalid
        }
    }
}

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct PaymentResponse: Codable {
    let code: String
    let message: String
    let cartId: String
    let totalAmount: String
    let checkout_url: String // Corrected property name
    let transaction: TransactionDetail?
}

struct TransactionDetail: Codable {
    let id: String
    let transaction_id: String
    let gateway_code: String
    let reference_id: String
    let custom_id: String
    let payment_method: String
    let currency: String
    let amount: String
    let charge: String
    let refunded: String
    let refund_charge: String
    let net: String
    let tips: String
    let status: String
    let paid_at: String
    let updated_at: String
}

    enum CodingKeys: String, CodingKey {
            case id
            case transaction_id
            case gateway_code
            case reference_id
            case custom_id
            case payment_method
            case currency
            case amount
            case charge
            case refunded
            case refund_charge
            case net
            case tips
            case status
            case paid_at
            case updated_at
            case builtAt = "builtAt"
            case cpCartId = "cpCartId"
            case items
        }

class PaymentViewModel: ObservableObject {
    @Published var totalAmount: String = "0.00"
    @Published var cartId: String = ""
    @Published var checkoutURL: String? = nil
    @Published var isCheckoutURLAvailable: Bool = false
    
    // Function to update totalAmount based on cart items
    func updateTotalAmount(cartItems: [CartItemDetail]) {
        let total = cartItems.reduce(0.0) { $0 + $1.subtotal }
        totalAmount = String(format: "%.2f", total)
    }
    
    // Function to set Cart ID
    private func setCartId(cartId: String) {
        self.cartId = cartId
    }
    
    func initiatePayment(cartId: String, cartItems: [CartItemDetail]) {
        // Set Cart ID before initiating payment
        self.setCartId(cartId: cartId)
        
        // Ensure Cart ID is set before initiating payment
        guard !self.cartId.isEmpty else {
            print("Error: Cart ID is not set.")
            return
        }
        
        // Update totalAmount before initiating payment
        self.updateTotalAmount(cartItems: cartItems)
        
        // Print statement for debugging
        print("Initiating payment for Cart ID: \(self.cartId), Amount: \(self.totalAmount)")
        
        // Call the function to send the payment initiation request
        self.initiatePaymentRequest()
    }
    
    // Function to fetch CartId for the current user
    private func fetchCartIdForCurrentUser(completion: @escaping (String) -> Void) {
        // Get the current user's UID from Firebase Authentication
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("Users").document(userId)
        
        // Replace this with your logic to fetch CartId from cartTransactions subcollection
        userRef.collection("cartTransactions").getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let cartId = documents.first?.documentID {
                completion(cartId)
            } else {
                print("Error: CartId not found.")
            }
        }
    }
    
    
    private func initiatePaymentRequest() {
        // Obtain Firebase ID token
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: User is not logged in.")
            return
        }
        
        currentUser.getIDToken { token, error in
            guard let token = token, error == nil else {
                print("Error obtaining ID token:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            // URL of your server's /initiate-payment endpoint
            guard let url = URL(string: "https://payment.everything-intelligence.com/initiate-payment") else {
                print("Error: Invalid URL")
                return
            }

            // Print statement for debugging
            print("Initiating payment request with Cart ID: \(self.cartId)")

            // Append the Firebase ID token to the Authorization header
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include Firebase ID token
            
            // Prepare the request body
            let requestBody: [String: Any] = [
                "cartId": self.cartId,
                "totalAmount": self.totalAmount
            ]

            // Convert the request body to Data
            guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
                print("Error: Failed to serialize JSON data")
                return
            }

            // Attach the JSON data to the request
            request.httpBody = jsonData

            // Create a URLSession task to send the request
            let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
                // Handle the response from the server
                if let data = data {
                    // Print the raw server response
                    print("Raw Server Response: \(String(data: data, encoding: .utf8) ?? "")")

                    // Check for a successful HTTP status code (2xx)
                    if let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) {
                        do {
                            let responseData = try JSONDecoder().decode(PaymentResponse.self, from: data)
                            print("Server Response: \(responseData)")

                            // Set the checkout URL received from the server
                            DispatchQueue.main.async {
                                self?.checkoutURL = responseData.checkout_url

                                // Check for the payment status before updating Firestore
                                if let status = responseData.transaction?.status, status.lowercased() == "paid" {
                                    // Extract Cart ID from the response
                                    let cartIdFromResponse = responseData.transaction?.custom_id ?? ""
                                    
                                    // Call the function to update Firestore for paid cart item
                                    self?.updateFirestoreForPaidCartItem(cartId: cartIdFromResponse)
                                }
                            }
                        } catch {
                            print("Error decoding response: \(error)")
                        }
                    } else {
                        // Print an error message for non-successful status codes
                        print("Server Error: \(HTTPURLResponse.localizedString(forStatusCode: (response as? HTTPURLResponse)?.statusCode ?? 0))")
                    }
                }

                if let error = error {
                    print("Error: \(error.localizedDescription)")
                }
            }

            // Start the URLSession task
            task.resume()
        }
    }

    
    // Function to update Firestore document to mark cart item as paid
    private func updateFirestoreForPaidCartItem(cartId: String) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: User is not logged in.")
            return
        }
        
        let db = Firestore.firestore()
        let cartRef = db.collection("Users").document(currentUserUID).collection("cartTransactions").document(cartId)
        
        cartRef.updateData(["paid": true]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Document successfully updated")
            }
        }
    }
}

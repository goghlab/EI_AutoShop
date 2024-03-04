import Foundation
import FirebaseAuth

struct PaymentResponse: Codable {
    let code: String
    let message: String
    let uid: String
    let totalAmount: String
    let token: String
    let checkoutURL: String
    let expiredAt: String

    enum CodingKeys: String, CodingKey {
        case code, message, uid, totalAmount, token
        case checkoutURL = "checkout_url"
        case expiredAt = "expired_at"
    }
}

class PaymentViewModel: ObservableObject {
    @Published var totalAmount: String = "0.00"
    @Published var uid: String = ""
    @Published var checkoutURL: String? = nil // New property to store checkout URL
    @Published var isCheckoutURLAvailable: Bool = false // Add this line
    
    // Function to update totalAmount based on cart items
    func updateTotalAmount(cartItems: [CartItemDetail]) {
        let total = cartItems.reduce(0.0) { $0 + $1.subtotal }
        totalAmount = String(format: "%.2f", total)
    }

    // Function to set UID
    private func setUID() {
        // Get the current user's UID from Firebase Authentication
        if let user = Auth.auth().currentUser {
            uid = user.uid
        } else {
            print("Error: User is not logged in.")
        }
    }

    // Function to initiate the payment process
    func initiatePayment(cartItems: [CartItemDetail]) {
        // Set UID before initiating payment
        setUID()

        // Ensure UID is set before initiating payment
        guard !uid.isEmpty else {
            print("Error: UID is not set.")
            return
        }

        // Update totalAmount before initiating payment
        updateTotalAmount(cartItems: cartItems)

        // Assuming you have a function to handle the payment process
        // You can replace the print statement with your actual logic
        print("Initiating payment for UID: \(uid), Amount: \(totalAmount)")

        // Call the function to send the payment initiation request
        initiatePaymentRequest()
    }

    private func initiatePaymentRequest() {
        // URL of your server's /initiate-payment endpoint
        guard var urlComponents = URLComponents(string: "https://payment.everything-intelligence.com/initiate-payment") else {
            print("Error: Invalid URL")
            return
        }

        // Set UID before initiating payment
        setUID()

        // Ensure UID is set before initiating payment
        guard !uid.isEmpty else {
            print("Error: UID is not set.")
            return
        }

        // Append the Referer header
        urlComponents.queryItems = [
            URLQueryItem(name: "Referer", value: "https://Payment.everything-intelligence.com"),
        ]

        guard let url = urlComponents.url else {
            print("Error: Invalid URL with Referer header")
            return
        }

        // Prepare the request body
        let requestBody: [String: Any] = [
            "uid": uid,
            "totalAmount": totalAmount
        ]

        // Convert the request body to Data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            print("Error: Failed to serialize JSON data")
            return
        }

        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        // Create a URLSession task to send the request
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            // Handle the response from the server
            if let data = data {
                do {
                    let responseData = try JSONDecoder().decode(PaymentResponse.self, from: data)
                    print("Server Response: \(responseData)")

                    // Set the checkout URL on the main thread
                    DispatchQueue.main.async {
                        self?.checkoutURL = responseData.checkoutURL
                    }
                } catch {
                    print("Error decoding response: \(error)")
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

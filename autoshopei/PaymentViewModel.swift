import Foundation
import FirebaseAuth

class PaymentViewModel: ObservableObject {
    @Published var totalAmount: String = "0.00"
    @Published var uid: String = ""
    
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

    // Function to send the payment initiation request to the server
    private func initiatePaymentRequest() {
        // URL of your server's /initiate-payment endpoint

        let urlString = "https://payment.everything-intelligence.com/initiate-payment"


        // Create the URL
        if let url = URL(string: urlString) {
            // Prepare the request body
            let requestBody: [String: Any] = [
                "uid": uid,
                "totalAmount": totalAmount
            ]

            // Convert the request body to Data
            if let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) {
                // Create the URLRequest
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData

                // Create a URLSession task to send the request
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    // Handle the response from the server (You can implement as needed)
                    if let data = data {
                        let responseData = String(data: data, encoding: .utf8)
                        print("Server Response: \(responseData ?? "No response data")")
                    }
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }

                // Start the URLSession task
                task.resume()
            }
        }
    }
}

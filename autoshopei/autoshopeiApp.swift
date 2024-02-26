//
//  autoshopeiApp.swift
//  autoshopei
//
//  Created by IZZY on 29/1/2024.
//

import SwiftUI
import Firebase

@main
struct autoshopeiApp: App {
    @StateObject private var paymentViewModel = PaymentViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environmentObject(paymentViewModel)
        }
    }
}


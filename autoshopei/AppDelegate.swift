import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "autoshop" {
            if url.host == "paymentsuccess" {
                // Handle the redirection to paymentsuccessView
                // Navigate to the appropriate view controller or SwiftUI view
            }
            return true
        }
        return false
    }
}
//
//  AppDelegate.swift
//  autoshopei
//
//  Created by IZZY on 29/2/2024.
//

import Foundation

//
//  AppDelegate.swift
//  NanoscalePush
//
//  Created by David Benko on 1/31/17.
//  Copyright © 2017 David Benko. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        /*
         * Register for APNS Remote Notifications
         */
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Reset badge number when user opens the app
        application.applicationIconBadgeNumber = 0
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Save apns token as hex string
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        subscribeToChannel(channel: "sample", token: token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote Notification Registration Error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Received APNS Push: \(userInfo)")
    }
    
    
    func subscribeToChannel(channel:String, token:String){
        // Set to your nanoscale.io host name
        let host = "https://daffy-jump-3233.nanoscaleapi.io"
        // Set to your remote endpoint code name
        let remoteEndpoint = "apns"
        
        // Create URLRequest
        let endpoint: String = "\(host)/push/\(remoteEndpoint)/subscribe"
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Set params
        let platform:String = "ios"
        let period:Int = 31536000
        let name:String = "my sample iPhone 7"
        
        // Create JSON payload body
        let params = ["platform":platform, "channel":channel, "period":period, "name":name, "token":token] as Dictionary<String, Any>
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: UInt(0)))

        }
        catch {
            print("Could not set body, JSON error")
        }
        
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Make the request
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            print("\(error)")
            print("\(response)")
        })
        task.resume()
    }
    
    func unsubscribeFromChannel(channel:String, token:String) {
        // Set to your nanoscale.io host name
        let host = "https://daffy-jump-3233.nanoscaleapi.io"
        // Set to your remote endpoint code name
        let remoteEndpoint = "apns"
        
        // Create URLRequest
        let endpoint: String = "\(host)/push/\(remoteEndpoint)/unsubscribe"
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Set params
        let platform:String = "ios"
        
        // Create JSON payload body
        let params = ["channel":channel, "platform":platform, "token":token] as Dictionary<String, Any>
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: UInt(0)))
            
        }
        catch {
            print("Could not set body, JSON error")
        }
        
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Make the request
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            print("\(error)")
            print("\(response)")
        })
        task.resume()
    }
    
    func publishToChannel(channel:String, payload:Dictionary<String, Any>){
        // Set to your nanoscale.io host name
        let host = "https://daffy-jump-3233.nanoscaleapi.io"
        // Set to your remote endpoint code name
        let remoteEndpoint = "apns"
        //Set environment
        let environment = "development"
        
        // Create URLRequest
        let endpoint: String = "\(host)/push/\(remoteEndpoint)/publish"
        guard let url = URL(string: endpoint) else {
            print("Error: cannot create URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // Set params
        let platform:String = "ios"
        
        let messagePayload = [platform:payload] as Dictionary<String, Any>
        
        // Create JSON payload body
        let params = ["payload":messagePayload, "channel":channel, "environment":environment] as Dictionary<String, Any>
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions(rawValue: UInt(0)))
            
        }
        catch {
            print("Could not set body, JSON error")
        }
        
        // Set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // Make the request
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            // do stuff with response, data & error here
            print("\(error)")
            print("\(response)")
        })
        task.resume()
    }


}


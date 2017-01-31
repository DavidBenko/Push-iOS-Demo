# nanoscale.io APNS Demo

Subscribe to recieve notifications on iOS using nanoscale.io

Instructions for your project:

* Create a class which conforms to `UNNotificationCenterDelegate` by linking to `UserNotifications.framework`, importing `UserNotifications` and adding `UNUserNotificationCenterDelegate` to the class declaration.  
* Add correct entitlements, certificates and provisioning profiles to your app
* Register for Remote Notifications
```swift 
/*
 * Register for APNS Remote Notifications
 */
let center = UNUserNotificationCenter.current()
center.delegate = self
center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
	// Enable or disable features based on authorization.
}
application.registerForRemoteNotifications() 
```
* If the user accepts and receives a device token for remote notifications, you will receive a call at `AppDelegate.application:didRegisterForRemoteNotificationsWithDeviceToken:`. You will need to save the device token as a hex string
```swift
// Save apns token as hex string
let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)}) 
```
* Once a device token is received, a channel needs to be subscribed to. Subscribing is done by sending an HTTP request to nanoscale at the subscribe endpoint, which using the default endpoint is:`POST {HOST}/push/{REMOTE ENDPOINT CODE NAME}/subscribe`. The body payload should be JSON with the following keys:
	* `platform`: String, the platform codename in your push remote endpoint
	* `period`: Integer, the time before your subscription expires
	* `name`: String, the name of the device (arbitrary)
	* `channel`: String, the name of the channel to which you’d like to subscribe
	* `token`: String, the device token in hex string format

* Example:
```swift
    func subscribeToChannel(channel:String, token:String){
        // Set to your nanoscale.io host name
        let host = "https://my-service.nanoscaleapi.io"
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
```



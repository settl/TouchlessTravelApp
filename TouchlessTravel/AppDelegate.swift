//
//  AppDelegate.swift
//  NoTouchTravel
//
//  Created by Anne-Sophie Ettl on 06.11.15.
//  Copyright © 2015 Hackathon. All rights reserved.
//

import UIKit
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {
    
    let httpClient = HTTPClient()
    var window: UIWindow?
    var tabbarController: UITabBarController!
    
    // Add a property to hold the beacon manager and instantiate it
    let beaconManager = ESTBeaconManager()
    
    let beaconRegion = CLBeaconRegion(
        proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 63333, minor: 34977,
        identifier: "beaconRegion2")
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("checkedIn") == nil) {
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: false), forKey: "checkedIn")
        }
        
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        self.beaconRegion.notifyOnEntry = true
        self.beaconRegion.notifyOnExit = true
        
        self.beaconManager.startMonitoringForRegion(self.beaconRegion)
        
        if self.window!.rootViewController as? UITabBarController != nil {
            self.tabbarController = self.window!.rootViewController as! UITabBarController
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleCheckIn:", name: "didEnterRegion", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleCheckOut:", name: "didExitRegion", object: nil)

        return true
    }
    
    func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("didEnterRegion", object: nil)
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: true), forKey: "checkedIn")
    }
    
    func beaconManager(manager: AnyObject, didExitRegion region: CLBeaconRegion) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("didExitRegion", object: nil)
        NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: false), forKey: "checkedIn")

    }
    
    func handleCheckIn(notification:NSNotification) {
        self.httpClient.sendEnterRegionRequest()
        
        let notification = UILocalNotification()
        notification.alertBody = "You entered U9 at Raitelsberg"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        let controller = self.tabbarController.viewControllers![self.tabbarController.selectedIndex]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("CheckIn")
        controller.presentViewController(vc, animated: true, completion: {
            self.performSelector(Selector("dismissCheckinViewController"), withObject: self, afterDelay: 4.0)
        })
    }
    
    func handleCheckOut(notification:NSNotification) {
        self.httpClient.sendLeaveRegionRequest()
        
        let notification = UILocalNotification()
        notification.alertBody = "You left U9 at Bergfriedhof"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
        let controller = self.tabbarController.viewControllers![self.tabbarController.selectedIndex]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewControllerWithIdentifier("CheckOut")
        
        controller.presentViewController(vc, animated: true, completion: {
            self.performSelector(Selector("dismissCheckinViewController"), withObject: self, afterDelay: 4.0)
        })

    }
    
    func dismissCheckinViewController() {
        
        let controller = self.tabbarController.viewControllers![self.tabbarController.selectedIndex]
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    /*func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
            if let nearestBeacon = beacons.first as? CLBeacon {
                NSLog("major: %d", nearestBeacon.major)
            }
    }*/
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("Error: %@", error);
    }
    
    func locationManager(manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        NSLog("Error: %@", error);
    }
    
    
    func locationManager(manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        NSLog("Error: %@", error);
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("willEnterForeground", object: nil)

        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    /*func sendRegionRequest(url: String) {
        
        let parameters = [
            "beaconId": beaconID,
            "userId": username,
            "timestamp": "234324234"
        ]
        
        Alamofire.request(.POST, server_url + url, parameters: parameters, encoding: .JSON)
            .responseJSON { response in
                print(response.request)  // original URL request
                NSLog("Enter region event sent")

                switch response.result {
                case .Success(let JSON):
                    print("Success with JSON: \(JSON)")
                    
                case .Failure(let error):
                    print("Request failed with error: \(error)")
                    
                    if let data = response.data {
                        print("Response data: \(NSString(data: data, encoding: NSUTF8StringEncoding)!)")
                    }
                }
        }
    }*/
}


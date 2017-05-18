//
//  AppDelegate.swift
//  NoTouchTravel
//
//  Created by Anne-Sophie Ettl on 06.11.15.
//  Copyright © 2015 Anne-Sophie Ettl. All rights reserved.
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
        proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 63333, minor: 34977,
        identifier: "beaconRegion2")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UserDefaults.standard.set(NSNumber(value: false as Bool), forKey: "checkedIn")

        UIApplication.shared.registerUserNotificationSettings(
            UIUserNotificationSettings(types: .alert, categories: nil))
        
        self.beaconManager.delegate = self
        self.beaconManager.requestAlwaysAuthorization()
        
        self.beaconRegion.notifyOnEntry = true
        self.beaconRegion.notifyOnExit = true
        
        self.beaconManager.startMonitoring(for: self.beaconRegion)
        
        if self.window!.rootViewController as? UITabBarController != nil {
            self.tabbarController = self.window!.rootViewController as! UITabBarController
        }
        
        setupNotifications()

        return true
    }
    
    func beaconManager(_ manager: Any, didEnter region: CLBeaconRegion) {
        
        // we may have already checked in via "Go!" button - in that case do nothing
        if (UserDefaults.standard.bool(forKey: "checkedIn") == false) {
            UserDefaults.standard.set(NSNumber(value: true as Bool), forKey: "checkedIn")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didEnterRegion"), object: nil)
        }
    }
    
    func beaconManager(_ manager: Any, didExit region: CLBeaconRegion) {
        
        // we may have already checked out via "Exit" button - in that case do nothing
        if (UserDefaults.standard.bool(forKey: "checkedIn") == true) {
            UserDefaults.standard.set(NSNumber(value: false as Bool), forKey: "checkedIn")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didExitRegion"), object: nil)
        }
    }
    
    func handleDidEnterRegion(_ notification:Notification) {
        
        self.httpClient.sendEnterRegionRequest()
        
        let notification = UILocalNotification()
        notification.alertBody = "You entered U9 at Raitelsberg"
        UIApplication.shared.presentLocalNotificationNow(notification)
        
        let controller = self.tabbarController.viewControllers![self.tabbarController.selectedIndex]
        
        // show modal viewcontroller instead of alertcontroller for final presentation
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "CheckIn")
        controller.present(vc, animated: true, completion: {
            self.perform(#selector(AppDelegate.dismissCheckinViewController), with: self, afterDelay: 1.0)
        })
    }
    
    func handleManualCheckIn(_ notification:Notification) {
        
        self.beaconManager.stopMonitoring(for: self.beaconRegion)
        UserDefaults.standard.set(NSNumber(value: true as Bool), forKey: "checkedIn")

        self.httpClient.sendEnterRegionRequest()
        
        let controller = self.tabbarController.viewControllers![self.tabbarController.selectedIndex]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "CheckIn")
        controller.present(vc, animated: true, completion: {
            self.perform(#selector(AppDelegate.dismissCheckinViewController), with: self, afterDelay: 1.0)
        })
    }
    
    func handleDidExitRegion(_ notification:Notification) {
        
        self.httpClient.sendLeaveRegionRequest()

        let notification = UILocalNotification()
        notification.alertBody = "You left U9 at Bergfriedhof"
        UIApplication.shared.presentLocalNotificationNow(notification)

        self.beaconManager.startMonitoring(for: self.beaconRegion)

        let controller = self.tabbarController.viewControllers![self.tabbarController.selectedIndex]
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "CheckOut")
        
        controller.present(vc, animated: true, completion: {
            self.perform(#selector(AppDelegate.dismissCheckinViewController), with: self, afterDelay: 1.0)
        })
    }
    
    func dismissCheckinViewController() {
        
        let controller = self.tabbarController.viewControllers![self.tabbarController.selectedIndex]
        controller.dismiss(animated: true, completion: nil)
    }
    /*func beaconManager(manager: AnyObject!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
            if let nearestBeacon = beacons.first as? CLBeacon {
                NSLog("major: %d", nearestBeacon.major)
            }
    }*/
    
    func locationManager(_ manager: CLLocationManager!, didFailWithError error: Error!) {
        print("Error: %@", error);
    }
    
    func locationManager(_ manager: CLLocationManager!, monitoringDidFailForRegion region: CLRegion!, withError error: NSError!) {
        NSLog("Error: %@", error);
    }
    
    func locationManager(_ manager: CLLocationManager!, rangingBeaconsDidFailForRegion region: CLBeaconRegion!, withError error: NSError!) {
        NSLog("Error: %@", error);
    }
    
    func setupNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handleDidEnterRegion(_:)), name: NSNotification.Name(rawValue: "didEnterRegion"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handleDidExitRegion(_:)), name: NSNotification.Name(rawValue: "didExitRegion"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handleManualCheckIn(_:)), name: NSNotification.Name(rawValue: "manualCheckIn"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "willEnterForeground"), object: nil)
        self.beaconManager.startMonitoring(for: self.beaconRegion)

        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
}


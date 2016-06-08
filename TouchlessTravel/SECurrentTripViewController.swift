//
//  SECurrentTripViewController.swift
//  TouchlessTravel
//
//  Created by Anne-Sophie Ettl on 07.11.15.
//  Copyright © 2015 Anne-Sophie Ettl. All rights reserved.
//

import Foundation
import UIKit

class SECurrentTripViewController: UIViewController {
    
    @IBOutlet weak var circleView : UIView?
    @IBOutlet weak var circleBackgroundView : UIView?
    @IBOutlet weak var currentTransportationLabel : UILabel?
    @IBOutlet weak var userNameLabel : UILabel?
    @IBOutlet weak var checkinStationLabel : UILabel?
    @IBOutlet weak var dateLabel : UILabel?
    @IBOutlet weak var timeLabel : UILabel?
    @IBOutlet weak var qrCodeView : UIImageView?
    
    let client = HTTPClient()
    var qrCodeImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Current Trip"
        
        setupLabels()
        setupNotifications()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        switchViews()
    }
    
    func startAnimation() {
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 0.6
        fadeAnimation.toValue = 0.0
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.3
        scaleAnimation.toValue = 1.2
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.0
        animationGroup.repeatCount = Float.infinity
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animationGroup.animations = [fadeAnimation, scaleAnimation]
        
        self.circleView!.layer.addAnimation(animationGroup, forKey: "scaleAndFade")
    }
 
    func createQRCode() {
        
        if self.qrCodeImage == nil {
            
            let url = self.client.createQRCodeFromURL()
            let data = url.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("Q", forKey: "inputCorrectionLevel")
            
            self.qrCodeImage = filter!.outputImage
            displayQRCodeImage()
        }
    }
    
    func displayQRCodeImage() {
        
        let scaleX = qrCodeView!.frame.size.width / qrCodeImage.extent.size.width
        let scaleY = qrCodeView!.frame.size.height / qrCodeImage.extent.size.height
        let transformedImage = qrCodeImage.imageByApplyingTransform(CGAffineTransformMakeScale(scaleX, scaleY))
        
        qrCodeView!.image = UIImage(CIImage: transformedImage)
    }
    
    func handleStateChange(notification:NSNotification) {
        
        self.performSelector(#selector(SECurrentTripViewController.switchViews), withObject: self, afterDelay: 0.2)
    }
    
    func switchViews() {
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("checkedIn") == true) {
            self.circleBackgroundView?.hidden = true
            self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Exit", style: .Plain, target: self, action: #selector(SECurrentTripViewController.buttonCheckOut)), animated: true)
            createQRCode()
        }
        else {
            self.circleBackgroundView?.hidden = false
            self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Go!", style: .Plain, target: self, action: #selector(SECurrentTripViewController.buttonCheckIn)), animated: true)
            startAnimation()
        }
    }
    
    func buttonCheckIn() {
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("checkedIn") == false) {
            
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: true), forKey: "checkedIn")
            NSNotificationCenter.defaultCenter().postNotificationName("manualCheckIn", object: nil)
        }
    }
    
    func buttonCheckOut() {
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("checkedIn") == true) {
            
            NSUserDefaults.standardUserDefaults().setObject(NSNumber(bool: false), forKey: "checkedIn")
            NSNotificationCenter.defaultCenter().postNotificationName("didExitRegion", object: nil)
        }
    }
    
    func setupLabels() {
        
        self.currentTransportationLabel!.layer.masksToBounds = true
        self.currentTransportationLabel!.layer.cornerRadius = 5.0
        self.userNameLabel!.layer.masksToBounds = true
        self.userNameLabel!.layer.cornerRadius = 5.0
        self.checkinStationLabel!.layer.masksToBounds = true
        self.checkinStationLabel!.layer.cornerRadius = 5.0
        self.dateLabel!.layer.masksToBounds = true
        self.dateLabel!.layer.cornerRadius = 5.0
        self.timeLabel!.layer.masksToBounds = true
        self.timeLabel!.layer.cornerRadius = 5.0
        
        self.dateLabel!.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .NoStyle)
        self.timeLabel!.text = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .NoStyle, timeStyle: .ShortStyle)
        
        self.circleView?.layer.cornerRadius = (self.circleView?.frame.size.height)!/2;
        self.circleBackgroundView?.hidden = true
    }
    
    func setupNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SECurrentTripViewController.handleStateChange(_:)), name: "didEnterRegion", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SECurrentTripViewController.handleStateChange(_:)), name: "didExitRegion", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SECurrentTripViewController.handleStateChange(_:)), name: "willEnterForeground", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SECurrentTripViewController.handleStateChange(_:)), name: "manualCheckIn", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
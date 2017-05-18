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
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        self.circleView!.layer.add(animationGroup, forKey: "scaleAndFade")
    }
 
    func createQRCode() {
        
        if self.qrCodeImage == nil {
            
            let url = self.client.createQRCodeFromURL()
            let data = url.data(using: String.Encoding.isoLatin1.rawValue, allowLossyConversion: false)
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
        let transformedImage = qrCodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        qrCodeView!.image = UIImage(ciImage: transformedImage)
    }
    
    func handleStateChange(_ notification:Notification) {
        
        self.perform(#selector(SECurrentTripViewController.switchViews), with: self, afterDelay: 0.2)
    }
    
    func switchViews() {
        
        if (UserDefaults.standard.bool(forKey: "checkedIn") == true) {
            self.circleBackgroundView?.isHidden = true
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Exit", style: .plain, target: self, action: #selector(SECurrentTripViewController.buttonCheckOut)), animated: true)
            createQRCode()
        }
        else {
            self.circleBackgroundView?.isHidden = false
            self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Go!", style: .plain, target: self, action: #selector(SECurrentTripViewController.buttonCheckIn)), animated: true)
            startAnimation()
        }
    }
    
    func buttonCheckIn() {
        
        if (UserDefaults.standard.bool(forKey: "checkedIn") == false) {
            
            UserDefaults.standard.set(NSNumber(value: true as Bool), forKey: "checkedIn")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "manualCheckIn"), object: nil)
        }
    }
    
    func buttonCheckOut() {
        
        if (UserDefaults.standard.bool(forKey: "checkedIn") == true) {
            
            UserDefaults.standard.set(NSNumber(value: false as Bool), forKey: "checkedIn")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "didExitRegion"), object: nil)
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
        
        self.dateLabel!.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        self.timeLabel!.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        
        self.circleView?.layer.cornerRadius = (self.circleView?.frame.size.height)!/2;
        self.circleBackgroundView?.isHidden = true
    }
    
    func setupNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(SECurrentTripViewController.handleStateChange(_:)), name: NSNotification.Name(rawValue: "didEnterRegion"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SECurrentTripViewController.handleStateChange(_:)), name: NSNotification.Name(rawValue: "didExitRegion"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SECurrentTripViewController.handleStateChange(_:)), name: NSNotification.Name(rawValue: "willEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SECurrentTripViewController.handleStateChange(_:)), name: NSNotification.Name(rawValue: "manualCheckIn"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

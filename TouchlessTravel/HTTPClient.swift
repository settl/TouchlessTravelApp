//
//  HTTPClient.swift
//  TouchlessTravel
//
//  Created by Anne-Sophie Ettl on 07.11.15.
//  Copyright © 2015 Anne-Sophie Ettl. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class HTTPClient {
    
    var delegate:HTTPClientDelegate? = nil
    
    let server_url = "https://touchless-travel.herokuapp.com/"
    let enter = "app/api/enter-region"
    let leave = "app/api/leave-region"
    let rides = "app/api/users/:id/rides"

    let username = "1" // some dummy data
    let beaconID = "63333"
    
    func createQRCodeFromURL() -> NSString {
        
        let timestamp = String(Date().timeIntervalSince1970)
        
        let urlString = server_url + "app/api/ticket-control?userId=" + username + "&" + "beaconId=" + beaconID +
            "&" + "timestamp=" + timestamp
        return urlString as NSString
    }
    
    func getRidesRequest() {
        Alamofire.request(server_url + "app/api/users/" + username + "/rides")
            .responseJSON { response in
                
                guard let value = response.result.value else {
                    print("Error: did not receive data")
                    return
                }
                
                guard response.result.error == nil else {
                    print("error calling GET on rides")
                    print(response.result.error)
                    return
                }
                
                let json = JSON(value)
                
                if let rides = json["rides"].array {
                    if(self.delegate != nil) {
                        self.delegate!.didReceiveData(rides)
                    }
                } else {
                    print("Error parsing /posts/1")
                }
        }
    }
    
    func sendEnterRegionRequest() {
        sendLeaveEnterRegionRequest(enter)
    }
    
    func sendLeaveRegionRequest() {
        sendLeaveEnterRegionRequest(leave)
    }
    
    func sendLeaveEnterRegionRequest(_ url: String) {
        
        let urlString: URLConvertible = server_url + url
        let timestamp = String(Date().timeIntervalSince1970)
        let parameters: Dictionary<String, Any> = [
            "beaconId": beaconID,
            "userId": username,
            "timestamp": timestamp
        ]
 
        Alamofire.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                print(response.request as Any)  // original URL request
                NSLog("Enter region event sent")
                
                switch response.result {
                case .success(let JSON):
                    print("Success with JSON: \(JSON)")
                    
                case .failure(let error):
                    print("Request failed with error: \(error)")
                    
                    if let data = response.data {
                        print("Response data: \(NSString(data: data, encoding: String.Encoding.utf8.rawValue)!)")
                    }
                }
        }
    }
    
}

protocol HTTPClientDelegate {
    func didReceiveData(_ json: [JSON])
}

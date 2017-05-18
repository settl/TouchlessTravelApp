//
//  FirstViewController.swift
//  TouchlessTravel
//
//  Created by Anne-Sophie Ettl on 06.11.15.
//  Copyright © 2015 Anne-Sophie Ettl. All rights reserved.
//

import UIKit
import SwiftyJSON

class SEReportsTableViewController: UITableViewController, HTTPClientDelegate {

    let httpClient = HTTPClient()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Travel Reports"
        self.httpClient.delegate = self
        self.httpClient.getRidesRequest()
    }

    func didReceiveData(_ json: [JSON]) {
        if let distance = json[0]["distance"].string{
            print(distance)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


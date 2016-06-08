//
//  FirstViewController.swift
//  TouchlessTravel
//
//  Created by Anne-Sophie Ettl on 06.11.15.
//  Copyright © 2015 Anne-Sophie Ettl. All rights reserved.
//

import UIKit
import SwiftyJSON

//no time to finish during hackathon :)
class SEReportTableViewController: UITableViewController, HTTPClientDelegate {
    
    let httpClient = HTTPClient()
    var datasource: [JSON] = []
    var cachedDatasource: NSDictionary = ["":""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Travel Reports"
        self.httpClient.delegate = self
        self.httpClient.getRidesRequest()
        
        getCachedJSON()
    }
    
    func didReceiveData(json: [JSON]) {
        self.datasource = json
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 1) {
            return 3
        }
        return 1
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
            cell.textLabel!.text = "November 2015"
            return cell
        }
        
        if (indexPath.section == 1) {
            let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath) as! SETripTableViewCell
            
            if (self.datasource[indexPath.row]["vehicle"]["vtype"].string == "TRAM") {
                cell.iconImageView!.image = UIImage(named: "icon-tram")
                cell.stationsImageView!.image = UIImage(named: "trip-tram")
            }
            else if (self.datasource[indexPath.row]["vehicle"]["vtype"].string == "TAXI") {
                cell.iconImageView!.image = UIImage(named: "icon-taxi")
                cell.stationsImageView!.image = UIImage(named: "trip-taxi")
            }
            cell.distanceLabel!.text = self.datasource[indexPath.row]["distance"].string
            cell.startStationLabel!.text = self.datasource[indexPath.row]["start"]["stationName"].string
            cell.destinationLabel!.text = self.datasource[indexPath.row]["stop"]["stationName"].string
            
            return cell
        }
        
        if (indexPath.section == 2 || indexPath.section == 4) {
            let cell = tableView.dequeueReusableCellWithIdentifier("MoreCell", forIndexPath: indexPath)
            return cell
        }
        
        if (indexPath.section == 3) {
            let cell = tableView.dequeueReusableCellWithIdentifier("OverviewCell", forIndexPath: indexPath)
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel!.text = "November 2015"
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 1) {
            return 80.0
        }
        if (indexPath.section == 3) {
            return 200.0
        }
        return 44.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCachedJSON() {
        if let path = NSBundle.mainBundle().pathForResource("cache", ofType: "json") {
            do {
                let data = try NSData(contentsOfURL: NSURL(fileURLWithPath: path), options: NSDataReadingOptions.DataReadingMappedIfSafe)
                let jsonObj = JSON(data: data)
                if jsonObj != JSON.null {
                    //print("jsonData:\(jsonObj)")
                    self.datasource = jsonObj.array!
                } else {
                    print("could not get json from file, make sure that file contains valid json.")
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
}


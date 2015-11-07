//
//  SETripTableViewCell.swift
//  TouchlessTravel
//
//  Created by Anne-Sophie Ettl on 07.11.15.
//  Copyright © 2015 Hackathon. All rights reserved.
//

import Foundation
import UIKit

class SETripTableViewCell: UITableViewCell {
    @IBOutlet weak var stationsView : UIView?
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        stationsView?.layer.cornerRadius = 8.0
    }
}

//
//  SETripTableViewCell.swift
//  TouchlessTravel
//
//  Created by Anne-Sophie Ettl on 07.11.15.
//  Copyright © 2015 Anne-Sophie Ettl. All rights reserved.
//

import Foundation
import UIKit

class SETripTableViewCell: UITableViewCell {
    @IBOutlet weak var stationsImageView : UIImageView?
    @IBOutlet weak var startStationLabel : UILabel?
    @IBOutlet weak var destinationLabel : UILabel?
    @IBOutlet weak var distanceLabel : UILabel?
    @IBOutlet weak var iconImageView : UIImageView?
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
}

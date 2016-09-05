//
//  PlaceListTableViewCell.swift
//  PlaceList
//
//  Created by Brad on 9/5/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit

class PlaceListTableViewCell: UITableViewCell {

    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateWithPlace(place: Place) {
        
        placeTitleLabel.text = place.title
        
        if let city = place.city, state = place.state {
            placeAddressLabel.text = "\(city), \(state)"
        } else {
            placeAddressLabel.text = place.title
        }
    }
}

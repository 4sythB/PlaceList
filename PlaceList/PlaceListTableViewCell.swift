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
        
        placeTitleLabel.textColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
        placeAddressLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        
        placeTitleLabel.text = place.title
        
        if let city = place.city, state = place.state {
            placeAddressLabel.text = "\(city), \(state)"
        } else {
            placeAddressLabel.text = place.title
        }
    }
}

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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func updateWithPlace(_ place: Place) {
        
        placeTitleLabel.text = place.title
        
        placeTitleLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        
        if SettingsController.sharedController.theme == .darkTheme {
            placeAddressLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        } else if SettingsController.sharedController.theme == .lightTheme {
            placeAddressLabel.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        }
        
        if let city = place.city, let state = place.state {
            placeAddressLabel.text = "\(city), \(state)"
        } else {
            placeAddressLabel.text = place.title
        }
    }
}













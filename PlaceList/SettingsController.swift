//
//  SettingsController.swift
//  PlaceList
//
//  Created by Brad on 9/14/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit

class SettingsController {
    
    static let sharedController = SettingsController()
    
    var theme: appearanceTheme = .darkTheme {
        didSet {
            toggleAppearanceTheme()
        }
    }
    
    enum appearanceTheme {
        case lightTheme
        case darkTheme
    }
    
    func toggleAppearanceTheme() {
        
        guard let titleFont = UIFont(name: "avenir-medium", size: 20),
            let font = UIFont(name: "avenir", size: 18) else { return }
        
        if theme == .darkTheme {
            
            UINavigationBar.appearance().barTintColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            UINavigationBar.appearance().tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0), NSFontAttributeName: titleFont]
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
            
            UITableView.appearance().backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            UITableViewCell.appearance().backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            
        } else if theme == .lightTheme {
            
            UINavigationBar.appearance().barTintColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            UINavigationBar.appearance().tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0), NSFontAttributeName: titleFont]
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
            
            UITableView.appearance().backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            UITableViewCell.appearance().backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            
            UILabel.appearance().textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            CopyableLabel.appearance().textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        }
    }
}












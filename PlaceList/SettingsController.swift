//
//  SettingsController.swift
//  PlaceList
//
//  Created by Brad on 9/14/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class SettingsController {
    
    static let sharedController = SettingsController()
    
    var mapType: MKMapType = .Standard {
        didSet {
            saveSettings()
        }
    }
    
    var theme: appearanceTheme = .darkTheme {
        didSet {
            toggleAppearanceTheme()
            saveSettings()
        }
    }
    
    enum appearanceTheme: String {
        case lightTheme = "light"
        case darkTheme = "dark"
    }
    
    func toggleAppearanceTheme() {
        if theme == .darkTheme {
            UITableView.appearance().backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            UITableViewCell.appearance().backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            
        } else if theme == .lightTheme {
            UITableView.appearance().backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            UITableViewCell.appearance().backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        }
    }
    
    func saveSettings() {
        NSUserDefaults.standardUserDefaults().setObject(theme.rawValue, forKey: "theme")
        NSUserDefaults.standardUserDefaults().setObject(mapType.rawValue, forKey: "mapType")
    }
    
    func loadSettings() {
        guard let themeRawValue = NSUserDefaults.standardUserDefaults().objectForKey("theme") as? appearanceTheme.RawValue,
            visualTheme = appearanceTheme(rawValue: themeRawValue),
            mapTypeRawValue = NSUserDefaults.standardUserDefaults().objectForKey("mapType") as? MKMapType.RawValue,
            mapTypeSelection = MKMapType(rawValue: mapTypeRawValue) else { return }
        
        self.theme = visualTheme
        self.mapType = mapTypeSelection
    }
}












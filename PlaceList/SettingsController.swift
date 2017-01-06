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
    
    var mapType: MKMapType = .standard {
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
        UserDefaults.standard.set(theme.rawValue, forKey: "theme")
        UserDefaults.standard.set(mapType.rawValue, forKey: "mapType")
    }
    
    func loadSettings() {
        guard let themeRawValue = UserDefaults.standard.object(forKey: "theme") as? appearanceTheme.RawValue,
            let visualTheme = appearanceTheme(rawValue: themeRawValue),
            let mapTypeRawValue = UserDefaults.standard.object(forKey: "mapType") as? MKMapType.RawValue,
            let mapTypeSelection = MKMapType(rawValue: mapTypeRawValue) else { return }
        
        self.theme = visualTheme
        self.mapType = mapTypeSelection
    }
}












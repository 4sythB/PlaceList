//
//  SettingsViewController.swift
//  PlaceList
//
//  Created by Brad on 9/14/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var themeHeadingLabel: UILabel!
    @IBOutlet weak var themeModeLabel: UILabel!
    @IBOutlet weak var mapTypeHeadingLabel: UILabel!
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        darkModeSwitch.onTintColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        darkModeSwitch.tintColor = UIColor(red:0.40, green:0.41, blue:0.43, alpha:1.00)
        
        if SettingsController.sharedController.theme == .darkTheme {
            darkModeSwitch.isOn = true
            self.view.backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            themeHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            themeModeLabel.textColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            mapTypeHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            mapTypeSegmentedControl.tintColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
        } else if SettingsController.sharedController.theme == .lightTheme {
            darkModeSwitch.isOn = false
            self.view.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            themeHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            themeModeLabel.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            mapTypeHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            mapTypeSegmentedControl.tintColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        }
        
        if SettingsController.sharedController.mapType == .standard {
            mapTypeSegmentedControl.selectedSegmentIndex = 0
        } else if SettingsController.sharedController.mapType == .hybrid {
            mapTypeSegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    // MARK: - Actions
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func darkModeSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            SettingsController.sharedController.theme = .darkTheme
            self.view.backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            themeHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            themeModeLabel.textColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            mapTypeHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            mapTypeSegmentedControl.tintColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
        } else {
            SettingsController.sharedController.theme = .lightTheme
            self.view.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            themeHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            themeModeLabel.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            mapTypeHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            mapTypeSegmentedControl.tintColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        }
    }
    
    @IBAction func mapTypeControlChanged(_ sender: AnyObject) {
        switch mapTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            SettingsController.sharedController.mapType = .standard
            return
        case 1:
            SettingsController.sharedController.mapType = .hybrid
            return
        default:
            break
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

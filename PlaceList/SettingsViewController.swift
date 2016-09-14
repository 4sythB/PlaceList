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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SettingsController.sharedController.theme == .darkTheme {
            darkModeSwitch.on = true
        } else if SettingsController.sharedController.theme == .lightTheme {
            darkModeSwitch.on = false
        }
    }
    
    // MARK: - Actions
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func darkModeSwitchChanged(sender: UISwitch) {
        if sender.on {
            SettingsController.sharedController.theme = .darkTheme
        } else {
            SettingsController.sharedController.theme = .lightTheme
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

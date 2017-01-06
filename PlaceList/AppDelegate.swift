//
//  AppDelegate.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SettingsController.sharedController.loadSettings()
        
        guard let titleFont = UIFont(name: "avenir-medium", size: 20),
            let font = UIFont(name: "avenir", size: 18) else { return true }
        
        UIApplication.shared.statusBarStyle = .lightContent
        UINavigationBar.appearance().barTintColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        UINavigationBar.appearance().tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0), NSFontAttributeName: titleFont]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], for: UIControlState())
        
        if SettingsController.sharedController.theme == .darkTheme {
            UITableView.appearance().backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            UITableViewCell.appearance().backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        } else if SettingsController.sharedController.theme == .lightTheme {
            UITableView.appearance().backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            UITableViewCell.appearance().backgroundColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        }
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        PlaceListViewController.locationManager.startUpdatingLocation()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
}







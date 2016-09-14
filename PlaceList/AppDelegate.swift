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


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        guard let titleFont = UIFont(name: "avenir-medium", size: 20),
            let font = UIFont(name: "avenir", size: 18) else { return true }
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        UINavigationBar.appearance().barTintColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        UINavigationBar.appearance().tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0), NSFontAttributeName: titleFont]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
        
        UITableView.appearance().backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        UITableViewCell.appearance().backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        PlaceListViewController.locationManager.startUpdatingLocation()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
}







//
//  DetailContainerViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class DetailContainerViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityStateZipLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var notesHeadingLabel: UILabel!
    
    var placemark: MKPlacemark?
    
    let placeholderText = "Type your notes here"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAppearance()
        setupLabelsAndMapView()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        notesTextView.delegate = self
        notesTextView.layer.cornerRadius = 8.0
        
        applyPlaceholderStyle(notesTextView, placeholderText: placeholderText)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupAppearance() {
        placeTitleLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        notesHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        
        if SettingsController.sharedController.theme == .darkTheme {
            view.backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            containerView.backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            streetAddressLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            cityStateZipLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            notesTextView.backgroundColor = UIColor(red:0.44, green:0.47, blue:0.51, alpha:1.00)
            notesTextView.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            notesTextView.keyboardAppearance = .dark
            
        } else if SettingsController.sharedController.theme == .lightTheme {
            view.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            containerView.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            streetAddressLabel.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            cityStateZipLabel.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            notesTextView.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.00)
            notesTextView.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            notesTextView.keyboardAppearance = .default
        }
    }
    
    func setupLabelsAndMapView() {
        guard let placemark = placemark else {
            print("Placemark is nil")
            return
        }
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        mapView.mapType = SettingsController.sharedController.mapType
        
        if let title = placemark.name {
            placeTitleLabel.text = title
        }
        
        if let subThoroughfare = placemark.subThoroughfare, let thoroughfare = placemark.thoroughfare {
            let streetAddress = "\(subThoroughfare) \(thoroughfare)"
            streetAddressLabel.text = streetAddress
            LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        } else {
            streetAddressLabel.isHidden = true
        }
        if let city = placemark.locality, let state = placemark.administrativeArea, let zipCode = placemark.postalCode {
            cityStateZipLabel.text = "\(city), \(state) \(zipCode)"
        } else {
            cityStateZipLabel.isHidden = true
        }
    }
    
    // MARK: - TextView placeholder
    
    func applyPlaceholderStyle(_ textView: UITextView, placeholderText: String) {
        textView.textColor = UIColor.lightGray
        textView.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(_ textView: UITextView) {
        textView.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        textView.alpha = 1.0
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == notesTextView && textView.text == placeholderText {
            moveCursorToStart(textView)
        }
        return true
    }
    
    func moveCursorToStart(_ textView: UITextView) {
        DispatchQueue.main.async(execute: {
            textView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            if textView == notesTextView && textView.text == placeholderText {
                if text.utf16.count == 0 { return false }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        } else {
            applyPlaceholderStyle(textView, placeholderText: placeholderText)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewDidChangeSelection (_ textView: UITextView) {
        if textView == notesTextView && textView.text == placeholderText {
            moveCursorToStart(textView)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if notesTextView.text.characters.count == 0 {
            notesTextView.text = placeholderText
            notesTextView.textColor = .lightGray
        }
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.size.height, 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
            scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height)
            
            scrollView.scrollRectToVisible((notesTextView.superview?.frame)!, animated: true)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: scrollView.contentSize.height)
    }
}

extension DetailContainerViewController: MKMapViewDelegate {
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}







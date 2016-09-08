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
    
    var placemark: MKPlacemark? = nil
    
    let placeholderText = "Type your notes here"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpContainerView()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        notesTextView.delegate = self
        notesTextView.layer.cornerRadius = 8.0
        
        applyPlaceholderStyle(notesTextView, placeholderText: placeholderText)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setUpContainerView() {
        
        // Appearance
        
        view.backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        containerView.backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        
        placeTitleLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        streetAddressLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        cityStateZipLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        notesHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        notesTextView.backgroundColor = UIColor(red:0.44, green:0.47, blue:0.51, alpha:1.00)
        notesTextView.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        
        notesTextView.keyboardAppearance = .Dark
        
        // Labels/MapView
        
        guard let placemark = placemark else { return }
        
        if let title = placemark.name {
            placeTitleLabel.text = title
        }
        if let subThoroughfare = placemark.subThoroughfare, thoroughfare = placemark.thoroughfare {
            let streetAddress = "\(subThoroughfare) \(thoroughfare)"
            streetAddressLabel.text = streetAddress
            LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        } else {
            streetAddressLabel.hidden = true
        }
        if let city = placemark.locality, state = placemark.administrativeArea, zipCode = placemark.postalCode {
            cityStateZipLabel.text = "\(city), \(state) \(zipCode)"
        } else {
            cityStateZipLabel.hidden = true
        }
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)

        notesTextView.font = UIFont(name: "avenir", size: 14)
    }
    
    // MARK: - TextView placeholder
    
    func applyPlaceholderStyle(textView: UITextView, placeholderText: String) {
        
        // make it look (initially) like a placeholder
        textView.textColor = UIColor.lightGrayColor()
        textView.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(textView: UITextView) {
        
        // make it look like normal text instead of a placeholder
        textView.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        textView.alpha = 1.0
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView == notesTextView && textView.text == placeholderText {
            // move cursor to start
            moveCursorToStart(textView)
        }
        return true
    }
    
    func moveCursorToStart(textView: UITextView) {
        dispatch_async(dispatch_get_main_queue(), {
            textView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        // remove the placeholder text when they start typing
        // first, see if the field is empty
        // if it's not empty, then the text should be black and not italic
        // BUT, we also need to remove the placeholder text if that's the only text
        // if it is empty, then the text should be the placeholder
        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 { // have text, so don't show the placeholder
            // check if the only text is the placeholder and remove it if needed
            // unless they've hit the delete button with the placeholder displayed
            if textView == notesTextView && textView.text == placeholderText {
                if text.utf16.count == 0 { // they hit the back button
                    return false // ignore it
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        } else {  // no text, so show the placeholder
            applyPlaceholderStyle(textView, placeholderText: placeholderText)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewDidChangeSelection (textView: UITextView) {
        // if placeholder is shown, prevent positioning of cursor within or selection of placeholder text
        if textView == notesTextView && textView.text == placeholderText {
            moveCursorToStart(textView)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if notesTextView.text.characters.count == 0 {
            notesTextView.text = placeholderText
            notesTextView.textColor = .lightGrayColor()
        }
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.size.height, 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height)
            
            scrollView.scrollRectToVisible((notesTextView.superview?.frame)!, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height)
    }
}







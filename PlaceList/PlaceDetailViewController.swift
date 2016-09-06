//
//  PlaceDetailViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class PlaceDetailViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityStateZipLabel: UILabel!
    @IBOutlet weak var notesHeadingLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    
    var place: Place?
    var placemark: MKPlacemark?
    
    let directionsButton = UIButton()
    
    let placeholderText = "Type your notes here"
    
    var mode: ButtonMode = .ViewMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        notesTextView.delegate = self
        notesTextView.editable = true
        notesTextView.layer.cornerRadius = 8.0
        
        if notesTextView.text == placeholderText {
            applyPlaceholderStyle(notesTextView, placeholderText: placeholderText)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setUpView() {
        
        // Appearance
        
        view.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        containerView.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        
        placeTitleLabel.textColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
        streetAddressLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        cityStateZipLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        notesHeadingLabel.textColor = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
        notesTextView.backgroundColor = UIColor(red:0.44, green:0.47, blue:0.51, alpha:1.00)
        notesTextView.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        
        // Directions Button
        
        let image = UIImage(named: "Arrow")?.imageWithRenderingMode(.AlwaysTemplate)
        directionsButton.frame = CGRectMake(0, 0, 23, 23) //won't work if you don't set frame
        directionsButton.setImage(image, forState: .Normal)
        directionsButton.tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        directionsButton.addTarget(self, action: #selector(PlaceDetailViewController.getDirections), forControlEvents: .TouchUpInside)
        
        let barButton = UIBarButtonItem()
        barButton.customView = directionsButton
        self.navigationItem.rightBarButtonItem = barButton
        
        // Labels/MapView
        
        guard let placemark = placemark, place = place, notes = place.notes else { return }
        
        let title = place.title
        
        if place.streetAddress == nil {
            streetAddressLabel.hidden = true
        } else {
            let streetAddress = place.streetAddress
            streetAddressLabel.text = streetAddress
        }
        
        if place.city == nil || place.state == nil || place.zipCode == nil {
            cityStateZipLabel.hidden = true
        } else {
            if let city = place.city, state = place.state, zipCode = place.zipCode {
                cityStateZipLabel.text = "\(city), \(state) \(zipCode)"
            }
        }
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        navigationItem.title = title
        
        placeTitleLabel.text = title
        notesTextView.text = notes
    }
    
    // MARK: - View mode
    
    enum ButtonMode {
        case ViewMode
        case EditMode
    }
    
    func goToEditMode() {
        
        directionsButton.removeFromSuperview()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(PlaceDetailViewController.goToViewMode))
        self.navigationItem.rightBarButtonItem = doneButton
        
        mode = .EditMode
        
        notesTextView.editable = true
    }
    
    func goToViewMode() {
        
        let barButton = UIBarButtonItem()
        barButton.customView = directionsButton
        self.navigationItem.rightBarButtonItem = barButton
        
        mode = .ViewMode
        
        notesTextView.resignFirstResponder()
        
        guard let place = place, notes = notesTextView.text else { return }
        
        PlaceController.sharedController.updateNotesForPlace(place, notes: notes)
    }
    
    func getDirections() {
        
        let mapItem = MKMapItem(placemark: placemark!)
        mapItem.name = place?.title
        mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    // MARK: - Action
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        
        goToViewMode()
    }
    
    // MARK: - Editing/saving
    
    func textViewDidBeginEditing(textView: UITextView) {
        goToEditMode()
    }
    
    override func viewWillDisappear(animated: Bool) {
        guard let place = place, notes = notesTextView.text else { return }
        
        PlaceController.sharedController.updateNotesForPlace(place, notes: notes)
    }
    
    // MARK: - TextView placeholder
    
    func applyPlaceholderStyle(textView: UITextView, placeholderText: String) {
        
        // make it look (initially) like a placeholder
        textView.textColor = UIColor.lightGrayColor()
        textView.text = placeholderText
        textView.font = UIFont(name: "avenir", size: 14)
    }
    
    func applyNonPlaceholderStyle(textView: UITextView) {
        
        // make it look like normal text instead of a placeholder
        textView.textColor = UIColor.darkTextColor()
        textView.alpha = 1.0
        textView.font = UIFont(name: "avenir", size: 14)
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










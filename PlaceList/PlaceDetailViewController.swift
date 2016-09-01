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
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var editDoneButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var place: Place?
    var placemark: MKPlacemark?
    
    let placeholderText = "Type your notes here"
    
    var mode: ButtonMode = .ViewMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        notesTextView.delegate = self
        
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
        
        guard let placemark = placemark, place = place, notes = place.notes else { return }
        
        let title = place.title, streetAddress = place.streetAddress, city = place.city, state = place.state, zip = place.zipCode
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        navigationItem.title = title
        
        
        placeTitleLabel.text = title
        streetAddressLabel.text = streetAddress
        cityStateZipLabel.text = "\(city), \(state) \(zip)"
        notesTextView.text = notes
        
        editDoneButton.title = "Edit"
        editDoneButton.style = .Plain
    }
    
    // MARK: - View mode
    
    enum ButtonMode {
        case ViewMode
        case EditMode
    }
    
    func goToEditMode() {
        
        editDoneButton.title = "Done"
        editDoneButton.style = .Done
        mode = .EditMode
        
        notesTextView.editable = true
    }
    
    func goToViewMode() {
        
        editDoneButton.title = "Edit"
        editDoneButton.style = .Plain
        mode = .ViewMode
        
        notesTextView.editable = false
        
        guard let place = place, notes = notesTextView.text else { return }
        
        PlaceController.sharedController.updateNotesForPlace(place, notes: notes)
    }
    
    // MARK: - Action
    
    @IBAction func viewModeButtonTapped(sender: AnyObject) {
        
        switch mode {
        case .ViewMode:
            goToEditMode()
            return
            
        case .EditMode:
            goToViewMode()
            return
        }
    }
    
    // MARK: - TextView placeholder
    
    func applyPlaceholderStyle(textView: UITextView, placeholderText: String) {
        
        // make it look (initially) like a placeholder
        textView.textColor = UIColor.lightGrayColor()
        textView.text = placeholderText
        textView.font = UIFont(name: "aventir", size: 18)
    }
    
    func applyNonPlaceholderStyle(textView: UITextView) {
        
        // make it look like normal text instead of a placeholder
        textView.textColor = UIColor.darkTextColor()
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










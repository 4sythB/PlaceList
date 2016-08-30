//
//  CustomSearchBar.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import UIKit

class CustomSearchBar: UISearchBar {
    
    init() {
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setShowsCancelButton(showsCancelButton: Bool, animated: Bool) {
    }
}
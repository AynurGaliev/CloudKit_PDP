//
//  ImagePickerView.swift
//  iCloud_PDP
//
//  Created by Aynur Galiev on 20.06.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class ImagePickerView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var saveCallback: ((title: String) -> Void)?
    
    class func createImagePicker() -> ImagePickerView {
        return NSBundle.mainBundle().loadNibNamed("ImagePickerView", owner: nil, options: nil).first as! ImagePickerView
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        self.saveCallback?(title: self.titleTextField.text ?? "")
    }
}

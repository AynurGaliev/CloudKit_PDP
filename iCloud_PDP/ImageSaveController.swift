//
//  ImageSaveController.swift
//  iCloud_PDP
//
//  Created by Galiev Aynur on 21.06.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class ImageSaveController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    
    var saveCallback: ((title: String) -> Void)?
    
    override func loadView() {
        super.loadView()
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.fs_width, height: 30))
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(ImageSaveController.doneAction(_:)))
        toolbar.setItems([doneButton], animated: true)
        self.titleTextField.inputAccessoryView = toolbar
    }
    
    func doneAction(sender: AnyObject) {
        self.titleTextField.resignFirstResponder()
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        self.saveCallback?(title: self.titleTextField.text ?? "")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

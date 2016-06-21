//
//  NewAlbumViewController.swift
//  iCloud_PDP
//
//  Created by Aynur Galiev on 20.06.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import CloudKit

class NewAlbumViewController: UIViewController {

    @IBOutlet weak var albumNameTextField: UITextField!
    @IBOutlet weak var saveOptionSwitch: UISwitch!
    
    var albumDidSaved: ((album: CKRecord, isPrivateRecord: Bool) -> Void)?
    
    @IBAction func saveAction(sender: UIButton) {
        let album = CKRecord(recordType: "Album")
        album.setObject(self.albumNameTextField.text, forKey: "name")
        
        let database = self.saveOptionSwitch.on ? PRIVATE_DATABASE : PUBLIC_DATABASE

        database.saveRecord(album, completionHandler: { (record: CKRecord?, error: NSError?) in
            
            UI_THREAD {
                
                if let lError = error {
                    let alert = UIAlertController(title: "Error", message: lError.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    if let lAlbum = record {
                        self.albumDidSaved?(album: lAlbum, isPrivateRecord: self.saveOptionSwitch.on)
                    }
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
}

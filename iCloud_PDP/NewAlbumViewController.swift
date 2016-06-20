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
    
    @IBAction func saveAction(sender: UIButton) {
        let album = CKRecord(recordType: "Album")
        album.setObject(self.albumNameTextField.text, forKey: "name")
        
        let database = self.saveOptionSwitch.on ? PRIVATE_DATABASE : PUBLIC_DATABASE

        database.saveRecord(album, completionHandler: { (record: CKRecord?, error: NSError?) in
            
            guard error == nil else {
                return
            }
            
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}

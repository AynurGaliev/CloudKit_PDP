//
//  PhotosCell.swift
//  iCloud_PDP
//
//  Created by Aynur Galiev on 20.06.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import CloudKit

class PhotosCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
    func prepareCell(photo: CKRecord) {
        self.photoImageView.image = photo.objectForKey("image") as? UIImage
        self.infoLabel.text = photo.objectForKey("name") as? String
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
        self.infoLabel.text = nil
    }
}

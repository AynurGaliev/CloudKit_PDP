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
        self.infoLabel.text = photo.objectForKey("title") as? String
        guard let asset = photo.objectForKey("image") as? CKAsset else { return }
        guard let data = NSData(contentsOfURL: asset.fileURL), let image = UIImage(data: data) else { return }
        self.photoImageView.image = image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
        self.infoLabel.text = nil
    }
}

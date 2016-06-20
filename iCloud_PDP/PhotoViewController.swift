//
//  PhotoViewController.swift
//  iCloud_PDP
//
//  Created by Aynur Galiev on 20.06.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import CloudKit

class PhotoViewController: UIViewController {

    private enum CellIdentifiers: String {
        case PhotosCell = "PhotosCell"
    }
    
    var album: CKRecord!
    var database: CKDatabase!
    
    private var photos: [CKRecord] {
        return self.album.objectForKey("photos") as? [CKRecord] ?? []
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        
        let imagePickerController = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePickerController.sourceType = .Camera
        } else {
            imagePickerController.sourceType = .PhotoLibrary
        }
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedRowHeight = 150
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
}

extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true) { 
            let pickerView = ImagePickerView.createImagePicker()
            self.view.addSubview(pickerView)
            pickerView.center = self.view.center
            pickerView.frame.size = CGSizeZero
            pickerView.imageView.image = image
            UIView.animateWithDuration(0.4, animations: { 
                pickerView.frame = CGRect(x: 20, y: 20, width: self.view.frame.size.width - 40, height: self.view.frame.size.height - 40)
                pickerView.layoutIfNeeded()
            })
            pickerView.saveCallback = { (title: String) -> Void in
                
                UIView.animateWithDuration(0.4, animations: { 
                    pickerView.frame = CGRect(origin: self.view.center, size: CGSizeZero)
                    pickerView.layoutIfNeeded()
                }, completion: { (success) in
                    pickerView.removeFromSuperview()
                })
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PhotoViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.PhotosCell.rawValue) as! PhotosCell
        cell.prepareCell(photos[indexPath.row])
        return cell
    }
}
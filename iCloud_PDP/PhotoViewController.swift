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
    
    private lazy var queue: NSOperationQueue = {
        let queue = NSOperationQueue()
        return queue
    }()
    
    var album: CKRecord! {
        didSet {
            if self.isViewLoaded() && self.album != nil {
                self.tableView.reloadData()
            }
        }
    }
    var database: CKDatabase!
    
    private var photos: [CKRecord] = []
    private var cursor: CKQueryCursor?
    private lazy var transitionDelegate: PresentationDelegate = {
        return PresentationDelegate(duration: 0.4)
    }()
    
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
        self.fetchPhotos()
    }
    
    override func viewWillLayoutSubviews() {
        self.tableView.contentInset = UIEdgeInsetsZero
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
            case "SaveImageSegue":
                let destinationVC = segue.destinationViewController as! ImageSaveController
                let image = sender as? UIImage
                destinationVC.view.frame = destinationVC.view.frame
                destinationVC.saveCallback = { (title: String) -> Void in
                    guard let lImage = image else { return }
                    self.saveRecord(lImage, title: title)
                }
                destinationVC.imageView?.image = image
                destinationVC.transitioningDelegate = self
                destinationVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            default: return
            
        }

    }
    
    func saveRecord(image: UIImage, title: String) {
        
        let asset = CKAsset(fileURL: image.saveToFile(title))
        let photo = CKRecord(recordType: "Photo")
        photo["image"] = asset
        photo["title"] = title
        let reference = CKReference(recordID: self.album.recordID, action: CKReferenceAction.DeleteSelf)
        photo["album"] = reference
        self.database.saveRecord(photo, completionHandler: { (photo: CKRecord?, error: NSError?) in
            
            if let record = photo where error == nil {
                UI_THREAD {
                    self.photos.append(record)
                    self.tableView.reloadData()
                }
            } else {
                UI_THREAD {
                    let alert = UIAlertController(title: "Save error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func fetchPhotos() {
        
        let query = CKQuery(recordType: "Photo", predicate: NSPredicate(format: "album == %@", self.album.recordID))
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.database = self.database
        queryOperation.cursor = self.cursor
        queryOperation.resultsLimit = 2
        queryOperation.queryCompletionBlock = { (cursor: CKQueryCursor?, error: NSError?) -> Void in
            UI_THREAD {
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    if let lCursor = cursor {
                        self.cursor = lCursor
                        self.fetchPhotos()
                    }
                }
            }
        }
        queryOperation.recordFetchedBlock = { (record: CKRecord) -> Void in
            UI_THREAD {
                self.photos.append(record)
                self.tableView.reloadData()
            }
        }
        self.queue.addOperation(queryOperation)
    }
}

extension UIImage {
    
    func saveToFile(named: String) -> NSURL {
        
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir: AnyObject = dirPaths[0]
        
        let filePath = docsDir.stringByAppendingPathComponent("currentImage.png")
        
        UIImageJPEGRepresentation(self, 0.5)?.writeToFile(filePath, atomically: true)
        
        return NSURL.fileURLWithPath(filePath)
    }
}

extension PhotoViewController: UIViewControllerTransitioningDelegate {
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return PopoverPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

extension PhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        self.dismissViewControllerAnimated(true) {
            self.performSegueWithIdentifier("SaveImageSegue", sender: image)
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

extension PhotoViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            self.database.deleteRecordWithID(self.photos[indexPath.row].recordID) { (recordID: CKRecordID?, error: NSError?) in
                
                UI_THREAD {
                    
                    if let lError = error {
                        let alert = UIAlertController(title: "Error", message: lError.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    } else {
                        self.photos.removeAtIndex(indexPath.row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Middle)
                    }
                }
            }
        }
    }
}
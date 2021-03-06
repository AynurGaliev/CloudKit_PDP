//
//  ViewController.swift
//  iCloud_PDP
//
//  Created by Aynur Galiev on 15.06.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit
import CloudKit

var PUBLIC_DATABASE: CKDatabase  {
   return CKContainer.defaultContainer().publicCloudDatabase
}

var PRIVATE_DATABASE: CKDatabase  {
    return CKContainer.defaultContainer().privateCloudDatabase
}

func UI_THREAD(UI_BLOCK: (()->())) {
    dispatch_async(dispatch_get_main_queue(), UI_BLOCK)
}

class AlbumsViewController: UIViewController {

    private var publicAlbums: [CKRecord] = [] {
        didSet {
            if self.publicAlbums.count != 0 {
                self.tableView.reloadData()
            }
        }
    }
    
    private var privateAlbums: [CKRecord] = [] {
        didSet {
            if self.privateAlbums.count != 0 {
                self.tableView.reloadData()
            }
        }
    }
    
    private enum HeaderIdentifiers: String {
        case AlbumHeader = "AlbumHeader"
    }
    
    private enum CellIdentifiers: String {
        case AlbumCell = "AlbumCell"
    }
    
    private enum SegueIdentifiers: String {
        case NewAlbumSegue = "NewAlbumSegue"
        case ShowDetailedAlbum = "ShowDetailedAlbum"
    }
    
    private enum Sections: Int {
        case Public  = 0
        case Private = 1
        
        var headerString: String {
            switch self {
            case .Private : return "Private albums"
            case .Public  : return "Public albums"
            }
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addAlbum(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(SegueIdentifiers.NewAlbumSegue.rawValue, sender: self)
    }
    
    private func getAlbums(section: Sections) -> [CKRecord] {
        switch section {
            case .Public  : return self.publicAlbums
            case .Private : return self.privateAlbums
        }
    }
    
    private func updateRecords(forSection section: Sections) {
        
        let database: CKDatabase = section == .Public ? PUBLIC_DATABASE : PRIVATE_DATABASE
        
        let query = CKQuery(recordType: "Album", predicate: NSPredicate(value: true))
        
        database.performQuery(query, inZoneWithID: nil) { (records: [CKRecord]?, error: NSError?) in
            
            if let lError = error, let ckError = CKErrorCode(rawValue: lError.code) {
                
                UI_THREAD {
                    switch ckError {
                        case .NotAuthenticated:
                            let alert = UIAlertController(title: "Error", message: lError.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                            alert.addAction(UIAlertAction(title: "Go to settings", style: UIAlertActionStyle.Default, handler: { Void in
                                if UIApplication.sharedApplication().canOpenURL(NSURL(string: "prefs:root=CASTLE")!) {
                                    UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=CASTLE")!)
                                } else {
                                    let alert = UIAlertController(title: "Error", message: "Failed to open iCloud settings", preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                            }))
                            UI_THREAD {
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                    default:
                        let alert = UIAlertController(title: "iCloud error", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "OK, got it", style: UIAlertActionStyle.Destructive, handler: nil)
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }
                return
                
            } else {
            
                UI_THREAD {
                    switch section {
                        case .Public  : self.publicAlbums  = records ?? []
                        case .Private : self.privateAlbums = records ?? []
                    }
                }
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        self.tableView.registerNib(UINib.init(nibName: "HeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: HeaderIdentifiers.AlbumHeader.rawValue)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.updateRecords(forSection: .Public)
        self.updateRecords(forSection: .Private)
    }
    
    override func viewWillLayoutSubviews() {
        self.tableView.contentInset = UIEdgeInsetsZero
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
            case SegueIdentifiers.ShowDetailedAlbum.rawValue:
                let destinationVC = segue.destinationViewController as! PhotoViewController
                let indexPath = sender as! NSIndexPath
                destinationVC.album = self.getAlbums(Sections(rawValue: indexPath.section)!)[indexPath.row]
                destinationVC.database = indexPath.section == 0 ? PUBLIC_DATABASE : PRIVATE_DATABASE
            case SegueIdentifiers.NewAlbumSegue.rawValue:
                let destinationVC = segue.destinationViewController as! NewAlbumViewController
                destinationVC.albumDidSaved = { (album: CKRecord, isPrivateRecord: Bool) -> Void in
                    UI_THREAD {
                        if isPrivateRecord {
                            self.privateAlbums.append(album)
                        } else {
                            self.publicAlbums.append(album)
                        }
                        self.tableView.reloadData()
                    }
                }
            default:
                return
        }
    }
}

extension AlbumsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Sections(rawValue: section) else { return 0 }
        return self.getAlbums(section).count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.AlbumCell.rawValue)!
        guard let section = Sections(rawValue: indexPath.section) else { return cell }
        cell.textLabel?.text = self.getAlbums(section)[indexPath.row].objectForKey("name") as? String
        return cell
    }
}

extension AlbumsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let section = Sections(rawValue: section) else { return nil }
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(HeaderIdentifiers.AlbumHeader.rawValue) as! HeaderView
        headerView.headerLabel.text = section.headerString
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(SegueIdentifiers.ShowDetailedAlbum.rawValue, sender: indexPath)
    }
}

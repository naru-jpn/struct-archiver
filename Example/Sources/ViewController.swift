//
//  ViewController.swift
//  StructArchiver
//
//  Created by naru on 2016/05/24.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit
import StructArchiver

class ViewController: UIViewController, UITableViewDelegate {

    // MARK: - Constants
    
    private struct Constants {
        
        static let SavedPath: String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] + "/samples.data"
        
        static let SuccessColor: UIColor = UIColor.grayColor()
        static let FailureColor: UIColor = UIColor(red: 1.0, green: 0.7, blue: 0.7, alpha: 0.9)
    }
    
    // MARK: - Elements
    
    lazy var tableView: UITableView = {
        let tableView: UITableView = UITableView(frame: self.view.bounds, style: .Grouped)
        tableView.dataSource = self.dataSource
        tableView.delegate = self
        return tableView
    }()

    lazy var dataSource: DataSource = {
        return DataSource()
    }()
    
    lazy var addItem: UIBarButtonItem = {
        let item: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(onAddItemTapped(_:)))
        return item
    }()
    
    lazy var actionItem: UIBarButtonItem = {
        let item: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(onActionItemTapped(_:)))
        return item
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.rightBarButtonItems = [self.actionItem, self.addItem]
        
        self.view.addSubview(self.tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Delegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    // MARK: - Actions
    
    @objc internal func onAddItemTapped(sender: UIBarButtonItem) {
        
        var inputTextField: UITextField?
        
        // Show alert to add sample
        let title: String = "Add Sample Struct"
        let message: String = "Please insert text to add."
        let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
        
            guard let inputTextField: UITextField = inputTextField, input: String = inputTextField.text else {
                return
            }
            
            // No input
            if input.characters.count == 0 {
                let alertController = UIAlertController(title: "No Input", message: "Plaese input some text to add.", preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            let title: String = input
            self.add(title: title)
            
        }))
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Text To Add"
            inputTextField = textField
        }
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @objc internal func onActionItemTapped(sender: UIBarButtonItem) {
        
        // Show action sheet
        let title: String = "Please select action"
        let alertController: UIAlertController = UIAlertController(title: title, message: "", preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Save Current Data", style: .Default, handler: { action in
            self.save()
        }))
        alertController.addAction(UIAlertAction(title: "Load Data", style: .Default, handler: { action in
            self.load()
        }))
        alertController.addAction(UIAlertAction(title: "Clear Data", style: .Destructive, handler: { action in
            self.clear()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Control Data
    
    private func add(title title: String) {
        
        let timestamp: Double = Double(NSDate().timeIntervalSince1970)
        let sample: SampleStruct = SampleStruct(title: title, timestamp: timestamp)
        self.dataSource.samples.insert(sample, atIndex: 0)
        
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    private func save() {
        
        let samples: Archivables = self.dataSource.samples
        
        // Archive sample data and save to file
        if !samples.archivedData.writeToFile(Constants.SavedPath, atomically: true) {
            
            let title: String = "Failed To Save"
            let alertController: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        self.completeAction(message: "Saved")
    }
    
    private func load() {
        
        guard let data: NSData = NSData(contentsOfFile: Constants.SavedPath) else {
            // No data
            let title: String = "No Data"
            let alertController: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        guard let samples: Archivables = Archiver.unarchive(data: data) as? Archivables else {
            // Failed to convert data
            let title: String = "Failed to convert data"
            let alertController: UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        self.dataSource.samples = samples
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 1)), withRowAnimation: .Automatic)
        
        self.completeAction(message: "Loaded")
    }
    
    private func clear() {
        
        if self.dataSource.samples.count == 0 {
            // No data to clear
            self.completeAction(message: "No data to clear", color: Constants.FailureColor)
            return
        }
        
        self.dataSource.samples = Archivables()
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, 1)), withRowAnimation: .Automatic)
        
        self.completeAction(message: "Cleared")
    }
    
    /// Show message notifying result
    /// - parameter message: message to show
    /// - parameter color: text color (default is color for success)
    private func completeAction(message message: String, color: UIColor = Constants.SuccessColor) {
        
        let label: UILabel = {
            let font: UIFont = UIFont.systemFontOfSize(15.0)
            let frame: CGRect = CGRectMake(0.0, (self.view.bounds.size.height-ceil(font.lineHeight))/2.0, self.view.bounds.size.width, ceil(font.lineHeight))
            let label: UILabel = UILabel(frame: frame)
            label.font = font
            label.textColor = color
            label.textAlignment = .Center
            label.text = message
            return label
        }()
        
        self.view.addSubview(label)
        UIView.animateWithDuration(2.0, animations: {
            label.alpha = 0.0
        }, completion: { finished in
            label.removeFromSuperview()
        })
    }
}

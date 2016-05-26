//
//  DataSource.swift
//  StructArchiver
//
//  Created by naru on 2016/05/24.
//  Copyright © 2016年 naru. All rights reserved.
//

import UIKit
import Foundation
import StructArchiver

public class DataSource: NSObject, UITableViewDataSource {
    
    public var samples: Archivables = Archivables()
    
    private lazy var dateFormatter: NSDateFormatter = {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        formatter.dateFormat = "yyyy.M.d H:m:ss"
        return formatter
    }()
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.samples.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell")
        if (cell == nil) {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
        }
        
        self.configulerCell(cell: cell!, indexPath: indexPath)
        return cell!
    }
    
    private func configulerCell(cell cell: UITableViewCell, indexPath: NSIndexPath) {
        
        guard let sample: SampleStruct = self.samples[indexPath.row] as? SampleStruct else {
            return
        }
        
        cell.textLabel?.font = UIFont.systemFontOfSize(15.0)
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(11.0)
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        
        let time: String = self.dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: sample.timestamp))
        cell.textLabel?.text = sample.title
        cell.detailTextLabel?.text = time
    }
}

//
//  SampleStruct.swift
//  StructArchiver
//
//  Created by naru on 2016/05/24.
//  Copyright © 2016年 naru. All rights reserved.
//

import Foundation

// Custom archivable struct for sample project
public struct SampleStruct: CustomArchivable {
    
    // Properties you want to store need to conform Archivable protocol.
    let title: String
    let timestamp: Double
    
    // Return closure to convert dictionary into struct
    public static var restoreProcedure: ArchiveRestoreProcedure {
        
        return { (dictionary: ArchivableDictionary) in
        
            if let title = dictionary["title"] as? String, let timestamp = dictionary["timestamp"] as? Double {
                return SampleStruct(title: title, timestamp: timestamp)
            }
            return SampleStruct(title: "", timestamp: 0.0)
        }
    }
}

//
//  StructArchiver.swift
//  StructArchiver
//
//  Created by naru on 2016/05/24.
//  Copyright © 2016年 naru. All rights reserved.
//

import Foundation

/// Closure to unarchive data
public typealias ArchiveUnarchiveProcedure = (data: NSData) -> Archivable

/// Closure to restore struct from unarchived dictionary
public typealias ArchiveRestoreProcedure = (dictionary: ArchivableDictionary) -> Archivable

/// Class to store procedures for Archive.
public class StructArchiver {
    
    /// Return shared archiver.
    public static let defaultArchiver: StructArchiver = StructArchiver()
    
    /// Store procedure to unarchive data.
    private var unarchiveProcedures: [String: ArchiveUnarchiveProcedure] = [String: ArchiveUnarchiveProcedure]()
    
    /// Store procedure to restore data.
    private var restoreProcedures: [String: ArchiveRestoreProcedure] = [String: ArchiveRestoreProcedure]()
    
    /// Register procedure to unarchive data.
    /// - parameter identifier: string to specify struct
    /// - parameter procedure: procedure to store
    public class func registerUnarchiveProcedure(identifier identifier: String, procedure: ArchiveUnarchiveProcedure) {
        self.defaultArchiver.unarchiveProcedures[identifier] = procedure
    }
    
    /// Register procedure to restore data.
    /// - parameter identifier: string to specify struct
    /// - parameter procedure: procedure to store
    public class func registerRestoreProcedure(identifier identifier: String, procedure: ArchiveRestoreProcedure) {
        self.defaultArchiver.restoreProcedures[identifier] = procedure
    }
    
    /// Return stored procedure to unarchive.
    /// - parameter identifier: string to specify struct
    /// - returns: stored procedure or nil if procedure for identifier is not stored
    public func unarchiveProcedure(identifier identifier: String) -> ArchiveUnarchiveProcedure? {
        guard let procedure: ArchiveUnarchiveProcedure = self.unarchiveProcedures[identifier] else {
            return nil
        }
        return procedure
    }
    
    /// Return stored procedure to retore struct.
    /// - parameter identifier: string to specify struct
    /// - returns: stored procedure or nil if procedure for identifier is not stored
    public func restoreProcedure(identifier identifier: String) -> ArchiveRestoreProcedure? {
        guard let procedure: ArchiveRestoreProcedure = self.restoreProcedures[identifier] else {
            return nil
        }
        return procedure
    }
    
    /// Unarchive data.
    /// - parameter data: data to unarchive
    /// - returns: unarchived object
    public func unarchive(data data: NSData) -> Archivable? {
        
        // length_of_identifier / others
        let splitData1: NSData.SplitData = data.split(length: sizeof(UInt8))
        var count: UInt8 = 0
        splitData1.former.getBytes(&count, length: sizeof(UInt8))
        
        // identifier / others
        let splitData2: NSData.SplitData = splitData1.latter.split(length: Int(count))
        let identifier = NSString(data: splitData2.former, encoding: NSUTF8StringEncoding) as? String ?? ""
                
        guard let procedure = self.unarchiveProcedure(identifier: identifier) else {
            return nil
        }
        
        let unarchived: Archivable = procedure(data: splitData2.latter)
        
        if let dictionary = unarchived as? ArchivableDictionary, let restoreProcedure = self.restoreProcedure(identifier: identifier) {
            return restoreProcedure(dictionary: dictionary)
        } else {
            return unarchived
        }
    }
    
    /// Unarchive data.
    /// - parameter data: data to unarchive
    /// - returns: unarchived object
    public class func unarchive(data data: NSData) -> Archivable? {
        return self.defaultArchiver.unarchive(data: data)
    }
    
    /// Register procedures for unarchiving and restoring struct.
    /// - parameter withCustomStructActivations: closure to register procedures for custom struct
    public class func activateStandardArchivables(withCustomStructActivations withCustomStructActivations:(() -> Void)?) {
        
        Int.activateArchive()
        UInt.activateArchive()
        Float.activateArchive()
        Double.activateArchive()
        String.activateArchive()
        Archivables.activateArchive()
        ArchivableDictionary.activateArchive()
        
        if let customStructActivations = withCustomStructActivations {
            customStructActivations()
        }
    }
}

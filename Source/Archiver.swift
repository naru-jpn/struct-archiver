//
//  Archiver.swift
//  StructArchiver
//
//  Created by naru on 2016/05/24.
//  Copyright © 2016年 naru. All rights reserved.
//

import Foundation

public class Archiver {
    
    /// Return shared archiver.
    public static let defaultArchiver: Archiver = Archiver()
    
    /// Stores identifiers for archibable types.
    /// Initialized [""] not to use index 0.
    private var archivableIdentifiers: [String] = [""]
    
    /// Stores procedure to unarchive data.
    private var unarchiveProcedures: [String: ArchiveUnarchiveProcedure] = [String: ArchiveUnarchiveProcedure]()
    
    /// Stores procedure to restore data.
    private var restoreProcedures: [String: ArchiveRestoreProcedure] = [String: ArchiveRestoreProcedure]()
    
    /// Return index of identifier and register new identifier if identifier is not registered.
    /// - parameter identifier: identifier string
    /// - returns: index of identifier
    public func archivableIdentifierIndex(identifier: String) -> Int {
        
        if self.archivableIdentifiers.contains( { $0 == identifier } ), let index = self.archivableIdentifiers.indexOf( { $0 == identifier } ) {
            return index
        }
        
        let count = self.archivableIdentifiers.count
        self.archivableIdentifiers.append(identifier)
        return count
    }
    
    /// Get identifier from data prefix.
    /// - parameter index: prefix of archived data
    /// - returns: identifier string if exist.
    public func archivableIdentifier(index: Int) -> String? {
        
        if index >= 0 && index < self.archivableIdentifiers.count {
            if let identifier: String = self.archivableIdentifiers[index] {
                return identifier
            }
        }
        return nil
    }
    
    public class func registerUnarchiveProcedure(identifier identifier: String, procedure: ArchiveUnarchiveProcedure) {
        
        self.defaultArchiver.unarchiveProcedures[identifier] = procedure
    }
    
    public class func registerRestoreProcedure(identifier identifier: String, procedure: ArchiveRestoreProcedure) {
        
        self.defaultArchiver.restoreProcedures[identifier] = procedure
    }
    
    public func unarchiveProcedure(identifier identifier: String) -> ArchiveUnarchiveProcedure? {
        
        guard let procedure: ArchiveUnarchiveProcedure = self.unarchiveProcedures[identifier] else {
            return nil
        }
        return procedure
    }
    
    public func restoreProcedure(identifier identifier: String) -> ArchiveRestoreProcedure? {
        
        guard let procedure: ArchiveRestoreProcedure = self.restoreProcedures[identifier] else {
            return nil
        }
        return procedure
    }
    
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
    
    public class func unarchive(data data: NSData) -> Archivable? {
        return self.defaultArchiver.unarchive(data: data)
    }
}

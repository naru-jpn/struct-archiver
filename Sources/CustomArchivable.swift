//
//  CustomArchivable.swift
//  StructArchiver
//
//  Created by naru on 2016/05/24.
//  Copyright © 2016年 naru. All rights reserved.
//

import Foundation

/// Protocol for custom archivable struct
public protocol CustomArchivable: Archivable, ElementArchivable {
    
    /// Closure to restore struct from unarchived dictionary.
    static var restoreProcedure: ArchiveRestoreProcedure { get }
}

public extension CustomArchivable {
    
    private func archivable() -> Archivable {
        
        var children: ArchivableDictionary = ArchivableDictionary()
        Mirror(reflecting: self).children.forEach { label, value in
            if let label = label, value = value as? Archivable {
                if let elementArchivable: ElementArchivable = value as? ElementArchivable {
                    children[label] = elementArchivable.archivable()
                } else {
                    children[label] = value
                }
            }
        }
        return children
    }
    
    public final var archivedIdentifier: String {
        return "\(Mirror(reflecting: self).subjectType)"
    }
    
    public static var archivedIdentifier: String {
        return "\(self)"
    }
    
    public var archivedDataLength: Int {
        
        let archivableChildren: ArchivableDictionary = self.archivable() as! ArchivableDictionary
        
        let elementsLength: Int = archivableChildren.keys.reduce(0) { (length, key) in
            length + key.archivedDataLength
        } + archivableChildren.values.reduce(0) { (length, value) in
            length + value.archivedDataLength
        }
        
        return self.archivedIDLength + Int.ArchivedDataLength*(1+archivableChildren.keys.count*2) + elementsLength
    }
    
    public var archivedHeaderData: [NSData] {
        let archivableChildren: ArchivableDictionary = self.archivable() as! ArchivableDictionary
        return archivableChildren.archivedHeaderData
    }
    
    public var archivedBodyData: [NSData] {
        let archivableChildren: ArchivableDictionary = self.archivable() as! ArchivableDictionary
        return archivableChildren.archivedBodyData
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return ArchivableDictionary.unarchiveProcedure
    }
    
    /// Store procedure to unarchive and restore data on memory.
    public static func activateArchive() {
        StructArchiver.registerUnarchiveProcedure(identifier: self.archivedIdentifier, procedure: self.unarchiveProcedure)
        StructArchiver.registerRestoreProcedure(identifier: self.archivedIdentifier, procedure: self.restoreProcedure)
    }
}

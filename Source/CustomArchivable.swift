//
//  CustomArchivable.swift
//  StructArchiver
//
//  Created by naru on 2016/05/24.
//  Copyright © 2016年 naru. All rights reserved.
//

import Foundation

public protocol CustomArchivable: Archivable {
    
    static var restoreProcedure: ArchiveRestoreProcedure { get }
}

public extension CustomArchivable {
    
    private var archivableChildren: ArchivableDictionary {
        
        var children: ArchivableDictionary = ArchivableDictionary()
        Mirror(reflecting: self).children.forEach { label, value in
            if let label = label, value = value as? Archivable {
                children[label] = value
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
        return self.archivableChildren.archivedDataLength
    }
    
    public func archivedHeaderData() -> [NSData] {
        return self.archivableChildren.archivedHeaderData()
    }
    
    public func archivedBodyData() -> [NSData] {
        return self.archivableChildren.archivedBodyData()
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return ArchivableDictionary.unarchiveProcedure
    }
    
    final public static func activateArchive() {
        Archiver.registerUnarchiveProcedure(identifier: self.archivedIdentifier, procedure: self.unarchiveProcedure)
        Archiver.registerRestoreProcedure(identifier: self.archivedIdentifier, procedure: self.restoreProcedure)
    }
}

//
//  Archivable.swift
//  StructArchiver
//
//  Created by naru on 2016/05/24.
//  Copyright © 2016年 naru. All rights reserved.
//

import Foundation

/// Protocol for mutual conversion of struct and NSData
public protocol Archivable {
    
    /// String to identify struct. (Implemented default behavior.)
//    static var archivedIdentifier: String { get }
    
    /// String to identify struct. (Implemented default behavior.)
//    var archivedIdentifier: String { get }
    
    /// Number of bytes of data to identify archived struct. (Implemented default behavior.)
//    var archivedIDLength: Int { get }
    
    /// Number of bytes of the whole archived data.
    var archivedDataLength: Int { get }
    
    /// Metadata for the archived data.
    var archivedHeaderData: [NSData] { get }
    
    /// Body data for the archived data.
    var archivedBodyData: [NSData] { get }
    
    /// The whole of archived data. (Implemented default behavior.)
//    var archivedData: NSData { get }
    
    /// Closure to unarchive data.
    static var unarchiveProcedure: ArchiveUnarchiveProcedure { get }
}

/// Represent array of archivable object.
public typealias Archivables = [Archivable]

/// Represent type of dictionary containing archivable value.
public typealias ArchivableDictionary = [String: Archivable]


/// Define default implementation for the Archivable.
public extension Archivable {

    /// Return name of type.
    public static var archivedIdentifier: String {
        return "\(self)"
    }

    /// Return name of type.
    public var archivedIdentifier: String {
        return "\(Mirror(reflecting: self).subjectType)"
    }
    
    /// Length of identifier data
    public var archivedIDLength: Int {
        return sizeof(UInt8) + self.archivedIdentifier.characters.count
    }
    
    /// Identifier data
    public var archivedIdentifierData: NSData {
        // count
        let identifier: String = self.archivedIdentifier
        var count: UInt8 = UInt8(identifier.characters.count)
        // + identifier string
        let identifierData: NSMutableData = NSMutableData(bytes: &count, length: sizeof(UInt8))
        if let data = identifier.dataUsingEncoding(NSUTF8StringEncoding) {
            identifierData.appendData(data)
        }
        return identifierData
    }
    
    /// Whole of archived data
    public var archivedData: NSData {
        let data: NSMutableData = NSMutableData(data: self.archivedIdentifierData)
        for subdata in self.archivedHeaderData + self.archivedBodyData {
            data.appendData(subdata)
        }
        return NSData(data: data)
    }
    
    /// Store procedure to unarchive data on memory.
    public static func activateArchive() {
        StructArchiver.registerUnarchiveProcedure(identifier: self.archivedIdentifier, procedure: self.unarchiveProcedure)
    }
}


extension Int: Archivable {

    public static let ArchivedDataLength: Int = sizeof(UInt8) + "Int".characters.count + sizeof(Int)
    
    public var archivedDataLength: Int {
        return Int.ArchivedDataLength
    }
    
    public var archivedHeaderData: [NSData] {
        return [NSData()]
    }
    
    public var archivedBodyData: [NSData] {
        var num: Int = self
        return [NSData(bytes: &num, length: sizeof(Int))]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return { data in
            // unarchive data as Int
            var value: Int = 0
            let data: NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Int)))
            data.getBytes(&value, length: sizeof(Int))
            return value
        }
    }
}

extension UInt: Archivable {
    
    public var archivedDataLength: Int {
        return self.archivedIDLength + sizeof(UInt)
    }
    
    public var archivedHeaderData: [NSData] {
        return [NSData()]
    }
    
    public var archivedBodyData: [NSData] {
        var value: UInt = self
        return [NSData(bytes: &value, length: sizeof(UInt))]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return { data in
            // unarchive data as UInt
            var value: UInt = 0
            let data: NSData = data.subdataWithRange(NSMakeRange(0, sizeof(UInt)))
            data.getBytes(&value, length: sizeof(UInt))
            return value
        }
    }
}

extension Float: Archivable {
    
    public var archivedDataLength: Int {
        return self.archivedIDLength + sizeof(Float)
    }
    
    public var archivedHeaderData: [NSData] {
        return [NSData()]
    }
    
    public var archivedBodyData: [NSData] {
        var value: Float = self
        return [NSData(bytes: &value, length: sizeof(Float))]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return { data in
            // unarchive data as Float
            var value: Float = 0
            let data: NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Float)))
            data.getBytes(&value, length: sizeof(Float))
            return value
        }
    }
}

extension Double: Archivable {
    
    public var archivedDataLength: Int {
        return self.archivedIDLength + sizeof(Double)
    }
    
    public var archivedHeaderData: [NSData] {
        return [NSData()]
    }
    
    public var archivedBodyData: [NSData] {
        var value: Double = self
        return [NSData(bytes: &value, length: sizeof(Double))]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return { data in
            // unarchive data as Double
            var value: Double = 0
            let data: NSData = data.subdataWithRange(NSMakeRange(0, sizeof(Double)))
            data.getBytes(&value, length: sizeof(Double))
            return value
        }
    }
}

extension String: Archivable {
    
    public var archivedDataLength: Int {
        return self.archivedIDLength + Int.ArchivedDataLength + self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
    }
    
    public var archivedHeaderData: [NSData] {
        let length: Int = self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        return [length.archivedData]
    }
    
    public var archivedBodyData: [NSData] {
        guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else {
            return [NSData()]
        }
        return [data]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        
        return { data in
            
            // get length of string
            let lengthData: NSData = data.subdataWithRange(NSMakeRange(0, Int.ArchivedDataLength))
            let length: Int = StructArchiver.defaultArchiver.unarchive(data: lengthData) as! Int
            
            // unarchive data as String
            let textRange = NSMakeRange(Int.ArchivedDataLength, length)
            let textData = data.subdataWithRange(textRange)
            let text = NSString(data: textData, encoding: NSUTF8StringEncoding) as? String ?? ""
            return text
        }
    }
}


public protocol ElementArchivable {
    func archivable() -> Archivable
}

extension Array: Archivable, ElementArchivable {
    
    public func archivable() -> Archivable {
        
        var archivables: Archivables = Archivables()
        self.forEach {
            if let archivable: Archivable = $0 as? Archivable {
                archivables.append(archivable)
            }
        }
        return archivables
    }
    
    public var archivedDataLength: Int {
        let archivables: Archivables = self.archivable() as! Archivables
        let elementsLength: Int = archivables.reduce(0, combine: {
            $0 + $1.archivedDataLength
        })
        return self.archivedIDLength + Int.ArchivedDataLength*(1+archivables.count) + elementsLength
    }
    
    public var archivedHeaderData: [NSData] {
        let archivables: Archivables = self.archivable() as! Archivables
        let count: NSData = archivables.count.archivedData
        let data: [NSData] = archivables.map { element in
            return element.archivedDataLength
        }.map { length in
            return length.archivedData
        }
        return [count] + data
    }
    
    public var archivedBodyData: [NSData] {
        let archivables: Archivables = self.archivable() as! Archivables
        let data: [NSData] = archivables.map { element in
            return element.archivedData
        }
        return data
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        
        return { data in
            
            // get number of elements
            let countData = data.subdataWithRange(NSMakeRange(0, Int.ArchivedDataLength))
            let count: Int = StructArchiver.unarchive(data: countData) as! Int
            
            let subdata: NSData = data.subdataWithRange(NSMakeRange(Int.ArchivedDataLength, data.length - Int.ArchivedDataLength))
            let splitData: NSData.SplitData = subdata.split(length: Int.ArchivedDataLength*count)
            
            // get lengths of each elements
            let lengths: [Int] = splitData.former.splitIntoSubdata(lengths: [Int](count: count, repeatedValue: Int.ArchivedDataLength)).map { element in
                return StructArchiver.unarchive(data: element) as! Int
            }
            
            // unarchive each elements
            let elements: [Archivable] = splitData.latter.splitIntoSubdata(lengths: lengths).flatMap { element in
                return StructArchiver.unarchive(data: element)
            }
            
            return elements
        }
    }
}

extension Dictionary: Archivable, ElementArchivable {
    
    public func archivable() -> Archivable {
        
        var archivableDictionary: ArchivableDictionary = ArchivableDictionary()
        for (label, value) in self {
            if let label = label as? String, value = value as? Archivable {
                archivableDictionary[label] = value
            }
        }
        return archivableDictionary
    }
    
    public var archivedDataLength: Int {
        
        let archivableDictionary: ArchivableDictionary = self.archivable() as! ArchivableDictionary
        
        let elementsLength: Int = archivableDictionary.keys.reduce(0) { (length, key) in
            length + key.archivedDataLength
        } + archivableDictionary.values.reduce(0) { (length, value) in
            length + value.archivedDataLength
        }
        
        return self.archivedIDLength + Int.ArchivedDataLength*(1+archivableDictionary.keys.count*2) + elementsLength
    }
    
    public var archivedHeaderData: [NSData] {
        
        let archivableDictionary: ArchivableDictionary = self.archivable() as! ArchivableDictionary
        
        // number of pair of key, value
        let count: NSData = Int(archivableDictionary.keys.count).archivedData
        
        // lengths of each key data
        let keys: [NSData] = archivableDictionary.keys.map { key in
            return key.archivedDataLength
        }.map { (length: Int) in
            return length.archivedData
        }
        
        // lengths of each value data
        let values: [NSData] = archivableDictionary.values.map { value in
            return value.archivedDataLength
        }.map { (length: Int) in
            return length.archivedData
        }
        
        return [count] + keys + values
    }
    
    public var archivedBodyData: [NSData] {
        
        let archivableDictionary: ArchivableDictionary = self.archivable() as! ArchivableDictionary
        
        let keys: [NSData] = archivableDictionary.keys.map { key in
            return key.archivedData
        }
        let values: [NSData] = archivableDictionary.values.map { value in
            return value.archivedData
        }
        return keys + values
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        
        return { data in
            
            // get number of pair of key, value
            let countData = data.subdataWithRange(NSMakeRange(0, Int.ArchivedDataLength))
            let count: Int = StructArchiver.unarchive(data: countData) as! Int
            
            let subdata: NSData = data.subdataWithRange(NSMakeRange(Int.ArchivedDataLength, data.length - Int.ArchivedDataLength))
            let splitData: NSData.SplitData = subdata.split(length: Int.ArchivedDataLength*count*2)
            
            // get lengths of each data
            let lengths: [Int] = splitData.former.splitIntoSubdata(lengths: [Int](count: count*2, repeatedValue: Int.ArchivedDataLength)).map { element in
                return StructArchiver.unarchive(data: element) as! Int
            }
            
            let bodyParts: [NSData] = splitData.latter.splitIntoSubdata(lengths: lengths)
            
            // get keys and values
            let keys: [String] = bodyParts[0..<count].flatMap { data in
                return StructArchiver.unarchive(data: data) as? String
            }
            let values: [Archivable] = bodyParts[count..<count*2].flatMap { data in
                return StructArchiver.unarchive(data: data)
            }
            
            // get result dictionary
            var dictionary: [String: Archivable] =  [String: Archivable]()
            keys.enumerate().forEach { index, key in
                dictionary[key] = values[index]
            }
            
            return dictionary
        }
    }
}

public extension NSData {
    
    typealias SplitData = (former: NSData, latter: NSData)
    
    func split(length length: Int) -> SplitData {
        let former: NSData = self.subdataWithRange(NSMakeRange(0, length))
        let latter: NSData = self.subdataWithRange(NSMakeRange(length, self.length - length))
        return (former: former, latter: latter)
    }
    
    func splitIntoSubdata(lengths lengths: [Int]) -> [NSData] {
        
        let data: NSData = NSData(data: self)
        var result: [NSData] = [NSData]()
        
        var position: Int = 0
        for length in lengths {
            let range: NSRange = NSMakeRange(position, length)
            result.append(data.subdataWithRange(range))
            position = position + length
        }
        return result
    }
}


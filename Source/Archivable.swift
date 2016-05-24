//
//  Archivable.swift
//  StructArchiver
//
//  Created by naru on 2016/05/24.
//  Copyright © 2016年 naru. All rights reserved.
//

import Foundation

public typealias Archivables = [Archivable]

public typealias ArchivableDictionary = [String: Archivable]

public typealias ArchiveUnarchiveProcedure = (data: NSData) -> Archivable

public typealias ArchiveRestoreProcedure = (dictionary: ArchivableDictionary) -> Archivable

public protocol Archivable {
    
    var archivedIdentifier: String { get } // default
    
    static var archivedIdentifier: String { get } // default
    
    var archivedIDLength: Int { get } // default
    
    var archivedDataLength: Int { get }
    
    func archivedIdentifierData() -> NSData // default
    
    func archivedHeaderData() -> [NSData]
    
    func archivedBodyData() -> [NSData]
    
    func archivedData() -> NSData // default
    
    static var unarchiveProcedure: ArchiveUnarchiveProcedure { get }
    
    static func activateArchive()
}

public extension Archivable {
    
    public var archivedIdentifier: String {
        return "\(Mirror(reflecting: self).subjectType)"
    }
    
    public static var archivedIdentifier: String {
        return "\(self)"
    }
    
    public var archivedIDLength: Int {
        return sizeof(UInt8) + self.archivedIdentifier.characters.count
    }
    
    public func archivedIdentifierData() -> NSData {
        
        let identifier: String = self.archivedIdentifier
        var count: UInt8 = UInt8(identifier.characters.count)
        let identifierData: NSMutableData = NSMutableData(bytes: &count, length: sizeof(UInt8))
        if let data = identifier.dataUsingEncoding(NSUTF8StringEncoding) {
            identifierData.appendData(data)
        }
        return identifierData
    }
    
    public final func archivedData() -> NSData {
        let data: NSMutableData = NSMutableData(data: self.archivedIdentifierData())
        for subdata in self.archivedHeaderData() + self.archivedBodyData() {
            data.appendData(subdata)
        }
        return data
    }
    
    public final static func activateArchive() {
        Archiver.registerUnarchiveProcedure(identifier: self.archivedIdentifier, procedure: self.unarchiveProcedure)
    }
}


extension Int: Archivable {

    public static let ArchivedDataLength: Int = sizeof(UInt8) + "Int".characters.count + sizeof(Int)
    
    public var archivedDataLength: Int {
        return Int.ArchivedDataLength
    }
    
    public func archivedHeaderData() -> [NSData] {
        return [NSData()]
    }
    
    public func archivedBodyData() -> [NSData] {
        var num: Int = self
        return [NSData(bytes: &num, length: sizeof(Int))]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return { data in
            var value: Int = 0
            let data: NSData = data.subdataWithRange(NSMakeRange(0, sizeof(UInt)))
            data.getBytes(&value, length: sizeof(UInt))
            return value
        }
    }
}

extension UInt: Archivable {
    
    public var archivedDataLength: Int {
        return self.archivedIDLength + sizeof(UInt)
    }
    
    public func archivedHeaderData() -> [NSData] {
        return [NSData()]
    }
    
    public func archivedBodyData() -> [NSData] {
        var value: UInt = self
        return [NSData(bytes: &value, length: sizeof(UInt))]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return { data in
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
    
    public func archivedHeaderData() -> [NSData] {
        return [NSData()]
    }
    
    public func archivedBodyData() -> [NSData] {
        var value: Float = self
        return [NSData(bytes: &value, length: sizeof(Float))]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return { data in
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
    
    public func archivedHeaderData() -> [NSData] {
        return [NSData()]
    }
    
    public func archivedBodyData() -> [NSData] {
        var value: Double = self
        return [NSData(bytes: &value, length: sizeof(Double))]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        return { data in
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
    
    public func archivedHeaderData() -> [NSData] {
        let length: Int = self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        return [length.archivedData()]
    }
    
    public func archivedBodyData() -> [NSData] {
        guard let data = self.dataUsingEncoding(NSUTF8StringEncoding) else {
            return [NSData()]
        }
        return [data]
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        
        return { data in
            
            let lengthData: NSData = data.subdataWithRange(NSMakeRange(0, Int.ArchivedDataLength))
            let length: Int = Archiver.defaultArchiver.unarchive(data: lengthData) as! Int
            
            let textRange = NSMakeRange(Int.ArchivedDataLength, length)
            let textData = data.subdataWithRange(textRange)
            let text = NSString(data: textData, encoding: NSUTF8StringEncoding) as? String ?? ""
            return text
        }
    }
}

extension Array: Archivable {
    
    private func archivableElements() -> [Archivable] {
        
        return self.flatMap { element in
            guard let element = element as? Archivable else {
                return nil
            }
            return element
        }
    }
    
    public var archivedDataLength: Int {
        let archivableElements: [Archivable] = self.archivableElements()
        let elementsLength: Int = archivableElements.reduce(0, combine: {
            $0 + $1.archivedDataLength
        })
        return self.archivedIDLength + Int.ArchivedDataLength*(1+archivableElements.count) + elementsLength
    }
    
    public func archivedHeaderData() -> [NSData] {
        let count: NSData = self.archivableElements().count.archivedData()
        let data: [NSData] = self.archivableElements().map { element in
            return element.archivedDataLength
            }.map { length in
                return length.archivedData()
        }
        return [count] + data
    }
    
    public func archivedBodyData() -> [NSData] {
        let data: [NSData] = self.archivableElements().map { element in
            return element.archivedData()
        }
        return data
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        
        return { data in
            
            let countData = data.subdataWithRange(NSMakeRange(0, Int.ArchivedDataLength))
            let count: Int = Archiver.defaultArchiver.unarchive(data: countData) as! Int
            
            let subdata: NSData = data.subdataWithRange(NSMakeRange(Int.ArchivedDataLength, data.length - Int.ArchivedDataLength))
            let splitData: NSData.SplitData = subdata.split(length: Int.ArchivedDataLength*count)
            
            let lengths: [Int] = splitData.former.splitIntoSubdata(lengths: [Int](count: count, repeatedValue: Int.ArchivedDataLength)).map { element in
                return Archiver.unarchive(data: element) as! Int
            }
            
            let elements: [Archivable] = splitData.latter.splitIntoSubdata(lengths: lengths).flatMap { element in
                print("\(element)")
                return Archiver.unarchive(data: element)
            }
            
            return elements
        }
    }
}


extension Dictionary: Archivable {
    
    private func archivableDictionary() -> [String: Archivable] {
        var dictionary: [String: Archivable] = [String: Archivable]()
        for (key, value) in self {
            if let key = key as? String, let value = value as? Archivable {
                dictionary[key] = value
            }
        }
        return dictionary
    }
    
    public var archivedDataLength: Int {
        
        let archivableDictionary: [String: Archivable] = self.archivableDictionary()
        
        let elementsLength: Int = archivableDictionary.keys.reduce(0) { (length, key) in
            length + key.archivedDataLength
            } + archivableDictionary.values.reduce(0) { (length, value) in
                length + value.archivedDataLength
        }
        
        return self.archivedIDLength + Int.ArchivedDataLength*(1+archivableDictionary.keys.count*2) + elementsLength
    }
    
    public func archivedHeaderData() -> [NSData] {
        
        // count of keys + count of values
        let count: NSData = Int(self.archivableDictionary().keys.count).archivedData()
        
        // lengths of each key data
        let keys: [NSData] = self.archivableDictionary().keys.map { key in
            return key.archivedDataLength
            }.map { (length: Int) in
                return length.archivedData()
        }
        
        // lengths of each value data
        let values: [NSData] = self.archivableDictionary().values.map { value in
            return value.archivedDataLength
            }.map { (length: Int) in
                return length.archivedData()
        }
        
        return [count] + keys + values
    }
    
    public func archivedBodyData() -> [NSData] {
        let keys: [NSData] = self.archivableDictionary().keys.map { key in
            return key.archivedData()
        }
        let values: [NSData] = self.archivableDictionary().values.map { value in
            return value.archivedData()
        }
        return keys + values
    }
    
    public static var unarchiveProcedure: ArchiveUnarchiveProcedure {
        
        return { data in
            
            // get count of pair
            let countData = data.subdataWithRange(NSMakeRange(0, Int.ArchivedDataLength))
            let count: Int = Archiver.defaultArchiver.unarchive(data: countData) as! Int
            
            // get data without count info
            let subdata: NSData = data.subdataWithRange(NSMakeRange(Int.ArchivedDataLength, data.length - Int.ArchivedDataLength))
            // split header part and body part
            let splitData: NSData.SplitData = subdata.split(length: Int.ArchivedDataLength*count*2)
            
            // get lengths
            let lengths: [Int] = splitData.former.splitIntoSubdata(lengths: [Int](count: count*2, repeatedValue: Int.ArchivedDataLength)).map { element in
                return Archiver.defaultArchiver.unarchive(data: element) as! Int
            }
            
            // split body
            let bodyParts: [NSData] = splitData.latter.splitIntoSubdata(lengths: lengths)
            // get keys and values
            let keys: [String] = bodyParts[0..<count].flatMap { data in
                return Archiver.unarchive(data: data) as? String
            }
            let values: [Archivable] = bodyParts[count..<count*2].flatMap { data in
                return Archiver.unarchive(data: data)
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

extension NSData {
    
    public typealias SplitData = (former: NSData, latter: NSData)
    
    public func split(length length: Int) -> SplitData {
        let former: NSData = self.subdataWithRange(NSMakeRange(0, length))
        let latter: NSData = self.subdataWithRange(NSMakeRange(length, self.length - length))
        return (former: former, latter: latter)
    }
    
    public func splitIntoSubdata(lengths lengths: [Int]) -> [NSData] {
        
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


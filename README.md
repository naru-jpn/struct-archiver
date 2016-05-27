# Struct Archiver

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/StructArchiver.svg)](https://img.shields.io/cocoapods/v/StructArchiver.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/StructArchiver.svg?style=flat)](http://cocoadocs.org/docsets/Alamofire)

Archive struct and fundamental values into NSData and unarchive.

## Features

+ [x] Archive/Unarchive Fundamental Values 
+ [x] Archive/Unarchive Custom Struct Values
+ [ ] Linux Build (for Swift3)

## Requirements
- iOS 8.0+
- Xcode 7.3+

## Communication
- If you __found a bug__, open an issue.
- If you __have a feature request__, open an issue.
- If you __want to contribute__, submit a pull request.

## Installation

### CocoaPods
```
pod 'StructArchiver'
```

### Carthage
```
github "naru-jpn/struct-archiver"
```

### Swift Packege Manager


## Activation
You need to activate Archiver before archiving/unarchiving as below.

```
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

	// Activate StructArchiver
	StructArchiver.activateStandardArchivables(withCustomStructActivations: {
		// Add activation if you create customArchivable struct 
	})
        
	// ...
        
	return true
}
```

## Usage

### Archive/Unarchive Fundamental Values
You can archive value of type conforming Archivable protocol and you can unarchive data by passing archived data to archiver.

```
	// Int
	let archivedInt: Int = -2016
	let archivedIntData: NSData = archivedInt.archivedData
	let unarchiveInt = Archiver.unarchive(data: archivedIntData) // -2016

	// Double
	let archivedDouble: Double = 2.016
	let archivedDoubleData: NSData = archivedDouble.archivedData
	let unarchivedDouble = Archiver.unarchive(data: archivedDoubleData) // 2016

	// String
	let archivedString: String = "archiving..."
	let archivedStringData: NSData = archivedString.archivedData
	let unarchiveString = Archiver.unarchive(data: archivedStringData) // "archiving..."
```

#### Value types you can archive
_Int_, _UInt_, _Float_, _Double_, _String_, _[Archibavle]_, _[String: Archibavle]_

### Archive/Unarchive Custom Struct Values 

#### 1. Define CustomArchivable Struct
Computed property restoreProcedure returns closure to convert dictionary into struct. Dictionary contains values of property having struct.

```
struct SampleStruct: CustomArchivable {
    
    // Archived values need to conform Archivable protocol.
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
```

#### 2. Add Activation
```
StructArchiver.activateStandardArchivables(withCustomStructActivations: {
	SampleStruct.activateArchive()
})
```

#### 3. Archive/Unarchive
You can archive/unarchive by the same way for fundamental values.

```
let archivedStruct: SampleStruct = SampleStruct(title: title, timestamp: timestamp)
// Archive
let archivedStructData: NSData = archivedStruct.archivedData
// Unarchive
let unarchivedStruct = Archiver.unarchive(data: archivedStructData)
```

### Archive/Unarchive Complex Values
You can archive array or dictionary containing archibavle values.

```
let archivedStruct1: SampleStruct = SampleStruct(title: title1, timestamp: timestamp1)
let archivedStruct2: SampleStruct = SampleStruct(title: title2, timestamp: timestamp2)
let archivedStruct3: SampleStruct = SampleStruct(title: title3, timestamp: timestamp3)

let archivedStructs: Archivables = [archivedStruct1, archivedStruct2, archivedStruct3]

// Archive
let archivedStructsData: NSData = archivedStructs.archivedData
// Unarchive
let unarchivedStructs = Archiver.unarchive(data: archivedStructsData)
```

See example project too. 

## License
MIT

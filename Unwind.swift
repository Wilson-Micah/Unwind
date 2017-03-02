//
//  Unwind.swift
//  Skip Shopper
//
//  Created by Micah Wilson on 2/23/17.
//  Copyright © 2017 Micah Wilson. All rights reserved.
//

import Foundation

infix operator <-
infix operator <-?

//Allows support for Arrays
infix operator <-|
infix operator <-|?

//Allows support for Arrays in JSON
postfix operator <-
postfix operator <-?

postfix operator <-|
postfix operator <-|?

public enum JSON {
    case dictionary(dictionary : [String : Any])
    case array(array: [Any])
    case error(error: Error)
    
    public init(_ response : Any) {
        switch response.self {
        case is [Any]:
            self = .array(array: response as! [Any])
        case is [String : Any]:
            self = .dictionary(dictionary: response as! [String : Any])
        case is Data:
            
            do {
                let parsedJSON = try JSONSerialization.jsonObject(with: response as! Data, options: JSONSerialization.ReadingOptions.allowFragments)
                
                switch parsedJSON {
                case is [String : Any]:
                    self = .dictionary(dictionary: parsedJSON as! [String : Any])
                case is [Any]:
                    self = .array(array: parsedJSON as! [Any])
                default:
                    self = .error(error: NSError())
                }
                
            } catch {
                self = .error(error: error)
            }
            
        case is Error:
            self = .error(error: response as! Error)
        default:
            self = .error(error: NSError(domain: "Unrecognized type in initializer", code: 500, userInfo: nil))
        }
    }
    
    public func hasError() -> Bool {
        switch self {
        case .error:
            return true
        default:
            return false
        }
    }
}

public protocol Unwind {
    init(json: JSON)
}


public extension JSON {
    //infix
    public static func <-<T>(json: JSON, string: String) -> T {
        guard let response: T = json <-? string else {
            
            //In case the type isn't optional it will return an empty string instead of crashing
            if T.self is String.Type {
                return "" as! T
            }
            
            fatalError("Unable to parse JSON for key: \(string)")
        }
        return response
    }
    
    public static func <-?<T>(json: JSON, string: String) -> T? {
        
        switch json {
        case let .dictionary(dictionary):
            
            let components = string.components(separatedBy: ".")
            if components.count > 1 {
                return json <-? components
            }
            
            if T.self is Unwind.Type {
                guard let newDict = dictionary[string] as? [String : Any] else { return nil }
                return (T.self as? Unwind.Type)?.init(json: JSON.dictionary(dictionary: newDict)) as? T
            }
            
            if let response = dictionary[string] as? T {
                
                //If type is optional then an empty string will return nil
                if response is String {
                    return (response as! String).isEmpty ? nil : response
                }
                
                return response
            }
            
            guard let response = dictionary[string] else { return nil }
            
            switch response.self {
            case is String:
                return (response as? String)?.tryConversionTo()
            case is Int:
                return (response as? Int)?.tryConversionTo()
            case is Bool:
                return (response as? Bool)?.tryConversionTo()
            case is Double:
                return (response as? Double)?.tryConversionTo()
            default:
                return nil
            }
        case let .array(array):
            
            if T.self is Unwind.Type {
                guard let newDict = array.first as? [String : Any] else { return nil }
                return (T.self as? Unwind.Type)?.init(json: JSON.dictionary(dictionary: newDict)) as? T
            }
            return array as? T
        default:
            return nil
        }
    }
    
    public static func <-<T>(json: JSON, strings: [String]) -> T {
        guard let response: T = json <-? strings else { fatalError("Unable to parse JSON for path: \(strings.joined(separator: " -> "))") }
        return response
    }
    
    public static func <-?<T>(json: JSON, strings: [String]) -> T? {
        switch json {
        case let .dictionary(dictionary):
            var dict: [String: Any]? = dictionary
            
            for str in strings {
                if str == strings.last {
                    guard let newDict = dict else { return nil }
                    return JSON(newDict) <-? str
                } else {
                    dict = dict?[str] as? [String : Any]
                }
            }
            
            return nil
        default:
            return nil
        }
    }
    
    public static func <-|<T>(json: JSON, string: String) -> [T] {
        guard let response: [T] = json <-|? string else { fatalError("Unable to parse JSON for key: \(string)") }
        return response
    }
    
    public static func <-|?<T>(json: JSON, string: String) -> [T]? {
        switch json {
        case let .dictionary(dictionary):
            guard let arr = dictionary[string] as? [Any] else { return nil }
            
            var results = [T]()
            
            for a in arr {
                guard let dict = a as? [String : Any] else { continue }
                let j = JSON([dict])
                guard let response: T = j<-? else { continue }
                results.append(response)
            }
            return results
            
        default:
            return nil
        }
    }
    
    public static func <-|<T>(json: JSON, strings: [String]) -> [T] {
        guard let response: [T] = json <-|? strings else { fatalError("Unable to parse JSON for path: \(strings.joined(separator: " -> "))") }
        return response
    }
    
    public static func <-|?<T>(json: JSON, strings: [String]) -> [T]? {
        switch json {
        case let .dictionary(dictionary):
            var dict: [String: Any]? = dictionary
            var resultDict: [Any]?
            
            for str in strings {
                if str == strings.last {
                    resultDict = dict?[str] as? [Any]
                } else {
                    dict = dict?[str] as? [String : Any]
                }
            }
            
            guard let arr = resultDict else { return nil }
            
            if let response = arr as? [T] {
                return response
            }
            
            var results = [T]()
            
            for a in arr {
                guard let dict = a as? [String : Any] else { continue }
                let j = JSON([dict])
                guard let response: T = j<-? else { continue }
                results.append(response)
            }
            return results
            
        default:
            return nil
        }
    }
    
    //postfix
    public static postfix func <-<T>(json: JSON) -> T {
        guard let response: T = json<-? else { fatalError("Unable to parse JSON. Make sure this is an array and not a dictionary.") }
        return response
    }
    
    public static postfix func <-?<T>(json: JSON) -> T? {
        switch json {
        case let .array(array):
            if T.self is Unwind.Type {
                guard let newDict = array.first as? [String : Any] else { return nil }
                return (T.self as? Unwind.Type)?.init(json: JSON.dictionary(dictionary: newDict)) as? T
            }
            return array as? T
        default:
            fatalError("Unable to parse JSON dictionary without a key")
        }
    }
    
    public static postfix func <-|<T>(json: JSON) -> [T] {
        guard let response: [T] = json<-|? else { fatalError("Unable to parse JSON. Make sure this is an array and not a dictionary.") }
        return response
    }
    
    public static postfix func <-|?<T>(json: JSON) -> [T]? {
        switch json {
        case let .array(array):
            var results = [T]()
            
            for a in array {
                guard let dict = a as? [String : Any] else { continue }
                let j = JSON([dict])
                guard let response: T = j<-? else { continue }
                results.append(response)
            }
            return results
        default:
            fatalError("Unable to parse JSON dictionary without a key")
        }
    }
}

extension String {
    
    var unwindDecimalValue : NSDecimalNumber {
        return NSDecimalNumber(string: self)
    }
    
    var unwindDoubleValue : Double {
        return NSString(string: self).doubleValue
    }
    
    var unwindIntValue : Int {
        return NSString(string: self).integerValue
    }
    
    var unwindInt32Value : Int32 {
        return NSString(string: self).intValue
    }
    
    var unwindUInt32Value : UInt32 {
        return UInt32(NSString(string: self).intValue)
    }
    
    var unwindUIntValue : UInt {
        return UInt(NSString(string: self).intValue)
    }
    
    var unwindFloatValue : Float {
        return NSString(string: self).floatValue
    }
    
    var unwindBoolValue : Bool {
        return NSString(string: self).boolValue
    }
    
    func tryConversionTo<T>() -> T? {
        switch T.self {
        case is Int.Type:
            return self.unwindIntValue as? T
        case is Int32.Type:
            return self.unwindInt32Value as? T
        case is UInt32.Type:
            return self.unwindUInt32Value as? T
        case is UInt.Type:
            return self.unwindUIntValue as? T
        case is Float.Type:
            return self.unwindFloatValue as? T
        case is CGFloat.Type:
            return CGFloat(self.unwindFloatValue) as? T
        case is Double.Type:
            return self.unwindDoubleValue as? T
        case is Bool.Type:
            return self.unwindBoolValue as? T
        case is URL.Type:
            return URL(string: self) as? T
        case is NSDecimalNumber.Type:
            return self.unwindDecimalValue as? T
        case is NSNumber.Type:
            return NumberFormatter().number(from: self) as? T
        case is Date.Type:
            
            if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue), let result = detector.firstMatch(in: self, options: [], range: NSMakeRange(0, self.characters.count)), result.resultType == NSTextCheckingResult.CheckingType.date, let date = result.date {
                return date as? T
            } else if self.isEmpty {
                return nil
            } else {
                return Date(timeIntervalSince1970: self.unwindDoubleValue) as? T //Epoch Time
            }
            
        default:
            return nil
        }
    }
}

extension Int {
    func tryConversionTo<T>() -> T? {
        switch T.self {
        case is String.Type:
            return "\(self)" as? T
        case is Bool.Type:
            return Bool(NSNumber(value: self)) as? T
        case is Float.Type:
            return Float(self) as? T
        case is CGFloat.Type:
            return CGFloat(self) as? T
        case is Double.Type:
            return Double(self) as? T
        case is NSDecimalNumber.Type:
            return NSDecimalNumber(value: self) as? T
        case is NSNumber.Type:
            return NSNumber(value: self) as? T
        case is Date.Type:
            return Date(timeIntervalSince1970: TimeInterval(self)) as? T //Epoch Time
        default:
            return nil
        }
    }
    
    init(_ bool:Bool) {
        self = bool ? 1 : 0
    }
}

extension Double {
    func tryConversionTo<T>() -> T? {
        switch T.self {
        case is String.Type:
            return "\(self)" as? T
        case is Int.Type:
            return Int(self) as? T
        case is Bool.Type:
            return Bool(NSNumber(value: self)) as? T
        case is Float.Type:
            return Float(self) as? T
        case is CGFloat.Type:
            return CGFloat(self) as? T
        case is NSDecimalNumber.Type:
            return NSDecimalNumber(value: self) as? T
        case is NSNumber.Type:
            return NSNumber(value: self) as? T
        case is Date.Type:
            return Date(timeIntervalSince1970: TimeInterval(self)) as? T //Epoch Time
        default:
            return nil
        }
    }
}

extension Bool {
    func tryConversionTo<T>() -> T? {
        switch T.self {
        case is String.Type:
            return "\(self)" as? T
        case is Int.Type:
            return Int(self) as? T
        case is NSNumber.Type:
            return NSNumber(value: self) as? T
        default:
            return nil
        }
    }
}

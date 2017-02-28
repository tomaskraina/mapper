//
//  GoOutTests.swift
//  Mapper
//
//  Created by Tom Kraina on 28/02/2017.
//  Copyright © 2017 Lyft. All rights reserved.
//

import Mapper
import XCTest


typealias Identifier = String
typealias BackendIdentifier = Int


extension Mapper {

    func identifierFrom(_ field: String) throws -> Identifier {
        return try from(field, transformation: { value in
            
            if let number = value as? BackendIdentifier {
                return Identifier(describing: number)
            } else if let number = value as? Identifier {
                return number
            }
            
            throw MapperError.typeMismatchError(field: field, value: value, type: Identifier.self)
        })
    }


    func identifierFrom(_ field: String) throws -> [Identifier] {
        return try from(field, transformation: { value in
            
            if let numbers = value as? [BackendIdentifier?] {
                return numbers.flatMap({
                    guard let number = $0 else { return nil }
                    return Identifier(describing: number)
                })
                
            } else if let numbers = value as? [Identifier?] {
                return numbers.flatMap({ $0 ?? nil })
            }
            
            throw MapperError.typeMismatchError(field: field, value: value, type: [Identifier].self)
        })
    }
}



final class GoOutTests: XCTestCase {
    
    func testCreateIdentifier() {
        
        struct Test: Mappable {
            let id: Identifier
            
            init(map: Mapper) throws {
                id = try map.identifierFrom("id")
            }
        }
        
        
        let JSONData = "{\"id\":123456789}".data(using: .utf8)!
        let JSONObject = try! JSONSerialization.jsonObject(with: JSONData, options: [])
        
        let test = Test.from(JSONObject as! NSDictionary)
        XCTAssertEqual(test?.id, "123456789")
    }
    
    
    func testCreateIdentifierArray() {
        
        struct Test: Mappable {
            let id: [Identifier]
            
            init(map: Mapper) throws {
                id = try map.identifierFrom("id")
            }
        }
        
        
        let JSONData = "{\"id\":[123456789,null]}".data(using: .utf8)!
        let JSONObject = try! JSONSerialization.jsonObject(with: JSONData, options: [])
        
        let test = Test.from(JSONObject as! NSDictionary)
        XCTAssertEqual(test!.id, ["123456789"])
    }
    
    func testCreateIdentifierStringArray() {
        
        struct Test: Mappable {
            let id: [Identifier]
            
            init(map: Mapper) throws {
                id = try map.identifierFrom("id")
            }
        }
        
        let JSONData = "{\"id\":[\"123456789\",null]}".data(using: .utf8)!
        let JSONObject = try! JSONSerialization.jsonObject(with: JSONData, options: [])
        
        let test = Test.from(JSONObject as! NSDictionary)
        XCTAssertEqual(test!.id, ["123456789"])
    }
    
}


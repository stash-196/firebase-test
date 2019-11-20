//
//  EncodableExtensions.swift
//  OKAN
//
//  Created by 朝永主竜珠 on 2019/05/03.
//  Copyright © 2019 OKAN. All rights reserved.
//

import Foundation

enum MyError: Error {
    case encodingError
    case fileNonExistant
}

extension Encodable {
    
    func toJson(excluding keys: [String] = [String]()) throws -> [String: Any] {
        let objectData =  try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: objectData, options: [])
        //Caution!! 'jsonObject' is 'Any'  -> see 1:01:00 https://www.youtube.com/watch?v=24ef-Zwz2v8
        guard var json = jsonObject as? [String: Any] else { throw MyError.encodingError }
        
        for key in keys {
            json[key] = nil
        }
        
        return json
    }
}

protocol FIRIdentifiable {
    var docId: String? { get set }
}

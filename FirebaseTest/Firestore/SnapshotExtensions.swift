//
//  SnapshotExtensions.swift
//  OKAN
//
//  Created by 朝永主竜珠 on 2019/05/03.
//  Copyright © 2019 OKAN. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension DocumentSnapshot {
	
	func decode< T: Decodable & Initializable >(as objectType: T.Type, includingDocId: Bool = true) throws -> T {
		
		var documentJson = data()
		if includingDocId {
			documentJson!["docId"] = documentID
		}
		
		let defaultT = T()
		let mirror = Mirror(reflecting: defaultT)
		_ = mirror.children.map {
			print("\($0.label!) => \($0.value)")
			if documentJson!["\($0.label!)"] == nil {
				documentJson!["\($0.label!)"] = $0.value
			}
		}
		
		print("ok")
		print(documentJson!)
		
		print("attempting serialization")
		let documentData = try JSONSerialization.data(withJSONObject: documentJson!, options: [])
		print("went through serialization")
		let decodedObject  = try JSONDecoder().decode(objectType, from: documentData)
		print("successfully decoded")
		return decodedObject
		
	}
}

//結局使ってないけど絶対便利 -> https://stackoverflow.com/questions/40358546/how-do-i-convert-nsdictionary-to-dictionary
extension NSDictionary {
    var swiftDictionary: Dictionary<String, Any> {
        var swiftDictionary = Dictionary<String, Any>()
        
        for key : Any in self.allKeys {
            let stringKey = key as! String
            if let keyValue = self.value(forKey: stringKey) {
                swiftDictionary[stringKey] = keyValue
            }
        }
        
        return swiftDictionary
    }
}

protocol Initializable {
    init()
}

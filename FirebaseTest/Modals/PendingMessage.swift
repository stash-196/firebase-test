//
//  PendingMessage.swift
//  FirebaseTest
//
//  Created by 朝永主竜珠 on 2019/11/06.
//  Copyright © 2019 OKAN. All rights reserved.
//

import Foundation

struct PendingMessage: Identifiable, FIRIdentifiable, Codable {
	var docId: String? = nil
	var id = UUID()
	var user: String
	var message: String
	var dueDate: Date
}

extension PendingMessage: Initializable {
	init() {
		self.user = "Lonely user"
		self.message = "研究してないで大丈夫？"
		self.dueDate = Date()
	}
	
	static let `default` = Self()
}


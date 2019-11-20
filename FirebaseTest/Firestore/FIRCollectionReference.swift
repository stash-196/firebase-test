//
//  FIRCollectionReference.swift
//  OKAN
//
//  Created by 朝永主竜珠 on 2019/05/03.
//  Copyright © 2019 OKAN. All rights reserved.
//

import Foundation

/// Firestore上のCollection名およびDocument名の型固定．
/// `.users`といった形で使用．
/// `users.rawValue`はString型．
enum MyCollectionReference: String {
    case users
	case relationships
    case chatList
    case chatData
    case templateReply
	case pendingMessages
    
	/// 特定のDocumentのIDを引数とし，そのDocument周りのReferenceを返す．
	/// 基本`.child`で補えるが，Collection内のDocument内のCollectionなどの深い層のReferenceが欲しい時用に作った．
    /// - Parameter myDocId: DocumentのIDをString型で入力．
	func goToLayer(_ myDocId: String) -> String {
        switch self {
        case .chatData:
			return "users/\(String(describing: myDocId))/chatData"
        case .templateReply:
			return "users/\(String(describing: myDocId))/chatData"
        default:
            return self.rawValue
        }
    }
}

/*enum FIRWHichReference: String {
    case document
    case collection
}*/

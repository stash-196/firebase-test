//
//  FIRFirestoreService.swift
//  okan-app
//
//  Created by 朝永主竜珠 on 2019/10/10.
//
import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore



class FIRFirestoreService {
	private init() {}
	static let shared = FIRFirestoreService()
	func configure() {
		FirebaseApp.configure()
	}
	
	private func reference(to collectionReference: MyCollectionReference, until id: String?=nil) -> CollectionReference {
		if id != nil {
			//Collectionの中のDocumentまでへのReference．まだ使っていないけど一応作っておいた．要らないかもしれない．
			return Firestore.firestore().collection(collectionReference.goToLayer( id! ))
		} else {
			//CollectionまでへのReference
			return Firestore.firestore().collection(collectionReference.rawValue)
		}
	}
	
	
	/// JSONにエンコードしたあとFirestoreにDocumentを作成する．
	///
	/// - Parameter encodableObject: FirestoreにDocumentとして送るオブジェクト．UserDataの場合は .profile 忘れるとエラー出るぞ．
	/// - Parameter collectionReference: Collectionを指定する．enum MyCollectionReferenceで型を確保してある．
	/// - Parameter id: 作成するDocumentのIDを指定したい場合．特別な理由がない限りあまり指定しない方がいい．
	func create< T: Encodable >(for encodableObject: T, in collectionReference: MyCollectionReference, as id: String?=nil) {
		do {
			//JSON形式にEncodeする．docId変数はFirestoreにあげる必要がないのでEncodeに含めない．
			let json = try encodableObject.toJson(excluding: ["docId"])
			if id != nil {
				//DocumentのIDを指定した場合のDocument作成．
				//あるかどうかは判別していないから既に存在するDocumentを上書きする可能性がある．
				//なので作成時にID指定はしない方がいい．
				reference(to: collectionReference).document(id!).setData(json)
			} else {
				//DocumentのIDを自動生成させる．特別な理由がない限りデフォルトでこれ使った方がいい．
				reference(to: collectionReference).addDocument(data: json)
			}
		} catch {
			print(error)
		}
	}


	/// コレクション内の全てのドキュメントを読み取り，指定した型（struct型など）へとDecodeしてリスト化する
	/// - Parameter collectionReference: Collectionを指定する．enum MyCollectionReferenceで型を確保してある．
	/// - Parameter objecType: 返して欲しい型名を指定する．'userData.profile.self' のように'.self'をつける．
	/// - Parameter completion: わからん．使ってない．
	func readAll< T: Decodable & Initializable >(fromCollection collectionReference: MyCollectionReference, returning objecType: T.Type, completion: @escaping([T]) -> Void) {
		
		reference(to: collectionReference).addSnapshotListener { (snapshot, _) in
			print("'read()' was successfully called")
			guard let snapshot = snapshot else {
				print("document data extraction error!")
				return
			}
			do {
				var objects = [T]()
				for document in snapshot.documents {
					let object = try document.decode(as: objecType.self)
					objects.append(object)
					//print(try document.decode(as: User.self))
				}
				completion(objects)
			} catch {
				print(error)
			}
		}
	}
	
	
	/// コレクション内のあるドキュメントを読み取って指定した型（structなど）へとDecodeする
	/// - Parameter collectionReference:  Collectionを指定する．enum MyCollectionReferenceで型を確保してある．
	/// - Parameter documentReference: 読みたいDocumentのID．
	/// - Parameter objecType: 返して欲しい型名を指定する．'userData.profile.self' のように'.self'をつける．
	/// - Parameter completion: 知〜ら〜ぬ．
	func read< T: Decodable & Initializable >(fromCollection collectionReference: MyCollectionReference, get documentReference: String, returning objecType: T.Type, completion: @escaping(T) -> Void) {
		
		reference(to: collectionReference).document(documentReference).getDocument { (snapshot, _) in
			print("'read(get: '\(documentReference)') was successfully called")
			guard let snapshot = snapshot else {
				print("document data extraction error!")
				return
			}
			do {
				let object = try snapshot.decode(as: objecType.self)
				//print(try document.decode(as: User.self))
				completion(object)
			} catch {
				print(error)
			}
		}
	}
	
	/*   reference(to: collectionReference).collection("products").whereField("instock", isEqualTo: true).getDocuments() { (querySnapshot, err) in
	if let err = err {
	print("Error getting documents: \(err)")
	} else {
	for document in querySnapshot!.documents {
	print("\(document.docId) => \(document.data())")
	}
	}
	}
	}*/
	
	
	/// 指定したIDのDocumentを更新する．
	/// - Parameter encodableObject: Firestoreに送る更新したオブジェクト．struct内の'docId'変数が'nil'だとエラーを返しちゃうぞ．
	/// - Parameter collectionReference: Collectionを指定する．enum MyCollectionReferenceで型を確保してある．
	func update< T: Encodable & FIRIdentifiable >(for encodableObject: T, in collectionReference: MyCollectionReference) {
		do {
			let json = try encodableObject.toJson(excluding: ["docId"])
			//struct内の'docId'変数が'nil'だとエラーを返しちゃうぞ．
			guard let docId = encodableObject.docId else { throw MyError.encodingError }
			reference(to: .users).document(docId).setData(json, merge: true)
		} catch {
			print(error)
		}
	}
	
	
	
	/// 手元にあるオブジェクトをFirestoreから消す．ただし，Firestoreからreadしたものに限る．
	/// - Parameter identifiableObject: Firestoreから消すオブジェクト．オブジェクト内の'docId'が'nil'だとエラーを返しちゃうぞ．
	/// - Parameter collectionReference: Collectionを指定する．enum MyCollectionReferenceで型を確保してある．
	func delete< T: FIRIdentifiable >(_ identifiableObject: T, in collectionReference: MyCollectionReference) {
		
		do {
			//オブジェクト内の'docId'が'nil'だとエラーを返しちゃうぞ．
			guard let docId =  identifiableObject.docId else { throw MyError.encodingError }
			//'この ID の Document を delete しろ'という命令を送る．あるかどうかは認識していない．
			reference(to: collectionReference).document(docId).delete()
		} catch {
			print(error)
		}
	}

	/*
	func search< T: Decodable >(for: , fromCollection collectionReference: MyCollectionReference, get documentReference: String, returning objecType: T.Type, completion: @escaping(T) -> Void) {
		
		reference(to: collectionReference).document(documentReference).getDocument { (snapshot, _) in
			print("'read(get: '\(documentReference)') was successfully called")
			guard let snapshot = snapshot else {
				print("document data extraction error!")
				return
			}
			do {
				let object = try snapshot.decode(as: objecType.self)
				//print(try document.decode(as: User.self))
				completion(object)
			} catch {
				print(error)
			}
		}
	}*/
}

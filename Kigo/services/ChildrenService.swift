//
//  ChildrenService.swift
//  Kigo-iPhone
//
//  Created by Florian on 13/05/2020.
//  Copyright © 2020 blandinf. All rights reserved.
//

import Foundation
import Firebase

class ChildrenService {
    static let db = Firestore.firestore()
    
    static func getChildren(completionHandler: @escaping ([Child], Error?) -> Void) {
        var childrenArray = [Child]()
        db.collection("child").getDocuments() { (querySnapshot, error) in
            if let err = error {
                completionHandler(childrenArray, err)
                return
            } else {
                for document in querySnapshot!.documents {
                    if let birthdate = document.data()["birthdate"] as? Timestamp {
                        if let child = Child(id: document.documentID, data: document.data(), birthdate: birthdate.dateValue()) {
                            childrenArray.append(child)
                        }
                    }
                }
                completionHandler(childrenArray, nil)
            }
        }
    }
    
    static func getChild(id: String, completionHandler: @escaping (Child?, Error?) -> Void) {
        var child: Child?
        db.collection("child").document(id).getDocument() { (document, error) in
            if let err = error {
                completionHandler(nil, err)
                return
            } else {
                if let document = document,
                    let data = document.data(),
                    let birthdate = data["birthdate"] as? Timestamp
                {
                    child = Child(id: document.documentID, data: data, birthdate: birthdate.dateValue())
                    completionHandler(child, nil)
                }
            }
        }
    }
    
    static func updateLocation(id: String, locationValue: Int) {
        db.collection("child").document(id)
          .getDocument() { (document, err) in
              document?.reference.updateData([
                  "location": locationValue
              ])
          }
    }
    
    static func updateActivity(id: String, activity: String) {
        db.collection("child").document(id)
          .getDocument() { (document, err) in
              document?.reference.updateData([
                  "activity": activity
              ])
          }
    }
    
    static func updateCurrentGame(id: String, currentGame: String) {
        db.collection("child").document(id)
          .getDocument() { (document, err) in
              document?.reference.updateData([
                  "currentGame": currentGame
              ])
          }
    }
    
    static func updateGamesNotAllowed(id: String, gamesNotAllowed: [String]) {
        db.collection("child").document(id)
        .getDocument() { (document, err) in
            document?.reference.updateData([
                "gamesNotAllowed": gamesNotAllowed
            ])
        }
    }
    
    static func updateChild(child: Child) {
        db.collection("child").document(child.id)
        .getDocument() { (document, err) in
            document?.reference.updateData([
                "firstname": child.firstname,
                "gender": child.gender
            ])
        }
    }
}

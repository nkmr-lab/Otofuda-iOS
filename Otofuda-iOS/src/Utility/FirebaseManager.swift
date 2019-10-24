//
//  FirebaseManager.swift
//  Uniotto-iOS
//
//  Created by Ryuhei Kaminishi on 2019/02/15.
//  Copyright © 2019 nshhhin. All rights reserved.
//

import Foundation
import Firebase

enum RoomURL: String {
    case base = "rooms/"
    case playMode = "/Otofuda/PlayMode"
    case mode = "/Otofuda/Mode"
}

enum ModeURL: String {
    case intro = "intro"
    case random = "random"
    case normal = "normal"
    case bingo = "bingo"
}

protocol FirebaseManagerProtocol: AnyObject {
    func post(path: String, value: Any)
    func deleteAllValue(path: String)
    func deleteObserve(path: String)
    func deleteAllValuesAndObserve(path: String)
    func observe(path: String, completion: @escaping(DataSnapshot) -> Void)
    func observeSingle(path: String, completion: @escaping(DataSnapshot) -> Void)
}

final class FirebaseManager: FirebaseManagerProtocol {
    static let shared = FirebaseManager()
    let dbRef = Database.database().reference()
}

extension FirebaseManager {

    func post(path: String, value: Any) {
        dbRef.child(path).setValue(value)
    }

    func deleteAllValue(path: String) {
        dbRef.child(path).removeValue()
    }

    func deleteObserve(path: String) {
        dbRef.child(path).removeAllObservers()
    }

    func deleteAllValuesAndObserve(path: String) {
        deleteAllValue(path: path)
        deleteObserve(path: path)
    }

    func observe(path: String, completion: @escaping (DataSnapshot) -> Void) {
        dbRef.child(path).observe(.value) { snapshot in
            completion(snapshot)
        }
    }

    func observeSingle(path: String, completion: @escaping (DataSnapshot) -> Void) {
        dbRef.child(path).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot)
        }
    }
}

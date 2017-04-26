//
//  SocketUser.swift
//  PerfectTemplate
//
//  Created by kokozu on 2017/4/25.
//
//

import Foundation

enum UserError: Error {
    case failedToCreate
}

class SocketUser: Hashable {
    var uid: String = ""
    var name: String = ""
    
    init(json:[String: Any]) throws {
        guard let userID = json["uid"] as? String else {
            throw UserError.failedToCreate
        }
        uid = userID
        
        if let userName = json["name"] as? String {
            name = userName
        }
    }
    
    init(_uid:String) {
        uid = _uid
        name = ""
    }
    
    init(_uid: String, _name: String) {
        uid = _uid
        name = _name
    }
    
    var hashValue: Int {
        return uid.hashValue
    }
    
    public static func ==(lhs: SocketUser, rhs: SocketUser) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func jsonDic() -> [String: String] {
        return ["uid": uid, "name": name]
    }
}

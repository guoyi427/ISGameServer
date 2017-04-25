//
//  SocketRoomManager.swift
//  PerfectTemplate
//
//  Created by kokozu on 2017/4/25.
//
//

import Foundation
import PerfectWebSockets

class SocketRoomManager {
    static let instance = SocketRoomManager()
    
    var rooms = [String:SocketRoom]()
    
    func creatRoom(json: [String:Any], socket: WebSocket) {
        guard let uid = json["uid"] as? String else {
            debugPrint("creat room error uid empty")
            return
        }
        if let room = rooms[uid] {
            debugPrint("room exist\(room.roomID)")
            return
        }
        let room = SocketRoom(uid: uid)
        rooms.updateValue(room, forKey: uid)
        
        //  创建成功    
        SocketManager.instance.sendMessage(json: ["message":"creatRoomSuccess"], socket: socket)
    }
    
    func inRoom(json:[String:Any], socket:WebSocket) {
        guard let uid = json["uid"] as? String, let name = json["name"] as? String, let roomID = json["room_id"] as? String else {
            debugPrint("in room error uid or name or room_id empty")
            return
        }
        
        guard let room = rooms[roomID] else {
            debugPrint("room not exist")
            return
        }
        
        let userModel = SocketUser(_uid: uid, _name: name)
        room.add(userModel: userModel)
        
        //  加入完成
        SocketManager.instance.sendMessage(json: ["message":"in room success"], socket: socket)
    }
    
    func outRoom(json:[String:Any], socket:WebSocket) {
        guard let uid = json["uid"] as? String, let name = json["name"] as? String, let roomID = json["room_id"] as? String else {
            debugPrint("out room error uid or name or room_id empty")
            return
        }
        
        guard let room = rooms[roomID] else {
            debugPrint("room not exist")
            return
        }
        
        let userModel = SocketUser(_uid: uid, _name: name)
        room.remove(userModel: userModel)
        
        //  退出房间完成
        SocketManager.instance.sendMessage(json: ["message":"out room success"], socket: socket)
    }
}

class SocketRoom {
    var chats = [String:SocketUser]()
    var roomID = ""
    
    init(uid:String) {
        roomID = uid
    }
    
    func add(userModel:SocketUser) {
        chats.updateValue(userModel, forKey: userModel.uid)
    }
    
    func remove(userModel:SocketUser) {
        chats.removeValue(forKey: userModel.uid)
    }
}

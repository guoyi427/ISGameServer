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
    
    /// 房间列表缓存 key:房主ID  value:房间对象
    var rooms = [String:SocketRoom]()
    
    /// 创建房间
    func creatRoom(json: [String:Any], socket: WebSocket) {
        guard let uid = json["uid"] as? String , let name = json["name"] as? String else {
            debugPrint("creat room error uid empty")
            return
        }
        
        //  生成 room id
        let roomID = uid + "\(arc4random()%100)"
        
        //  判断房间是否已经存在
        if let room = rooms[roomID] {
            debugPrint("room exist\(room.room_id)")
            inRoom(json: json, socket: socket)
            return
        }
        
        //  创建房间
        let room = SocketRoom(roomID: roomID)
        rooms.updateValue(room, forKey: roomID)
        
        //  将自己 加入房间
        let userModel = SocketUser(_uid: uid, _name: name)
        room.add(userModel: userModel)
        
        //  创建成功
        SocketManager.instance.sendJSON(socket: socket,
                                        json: ["message":["room_id":room.room_id],
                                               "code":SocketCode.CreatRoom.rawValue])
    }
    
    /// 加入房间
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
        SocketManager.instance.sendJSON(socket: socket, json: ["message":["room_id":room.room_id], "code":SocketCode.InRoom.rawValue])
    }
    
    /// 退出房间
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
        
        //  判断是否需要销毁房间
        if room.chats.count == 0 {
            rooms.removeValue(forKey: room.room_id)
        }
        
        //  退出房间完成
        SocketManager.instance.sendJSON(socket: socket, json: ["message":["room_id":room.room_id], "code":SocketCode.OutRoom.rawValue])
    }
    
    /// 查询房间列表
    func queryRoomList(socket:WebSocket) {
        var roomsArray:[[String:Any]] = []
        for roomDic in rooms {
            var roomInfoDic:[String:Any] = ["room_id": roomDic.value.room_id,
                               "uid": roomDic.key]
            var userList:[[String:String]] = []
            for userInfo in roomDic.value.chats {
                userList.append(userInfo.value.jsonDic())
            }
            roomInfoDic.updateValue(userList, forKey: "userList")
            roomsArray.append(roomInfoDic)
        }
        
        SocketManager.instance.sendJSON(socket: socket, json: ["message": roomsArray, "code": SocketCode.QueryRoomList.rawValue])
    }
    
    /// 群聊天
    func groupChat(json:[String:Any], socket: WebSocket) {
        guard let roomID = json["room_id"] as? String, let message = json["message"], let uid = json["uid"] as? String else {
            debugPrint("group chat error, para error")
            return
        }
        
        guard let room = rooms[roomID] else {
            debugPrint("group chat error, room is not exist")
            return
        }
        
        DispatchQueue.global().async {
            for toUser in room.chats.values {
                if let toUserSocket = SocketManager.instance._chats[toUser] {
                    SocketManager.instance.sendJSON(socket: toUserSocket, json: ["message":message,
                                                                                 "code":SocketCode.Group.rawValue,
                                                                                 "uid":uid])
                }
            }
        }
    }
}

class SocketRoom {
    var chats = [String:SocketUser]()
    var room_id = ""
    
    init(roomID:String) {
        room_id = roomID
    }
    
    func add(userModel:SocketUser) {
        chats.updateValue(userModel, forKey: userModel.uid)
    }
    
    func remove(userModel:SocketUser) {
        chats.removeValue(forKey: userModel.uid)
    }
}

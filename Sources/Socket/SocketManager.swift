//
//  SocketManager.swift
//  PerfectTemplate
//
//  Created by kokozu on 2017/4/24.
//
//

import Foundation
import PerfectWebSockets

class SocketManager {
    static let instance = SocketManager()
    
    /// 缓存在线用户 key:SocketUser对象, value:socket对象
    var _chats = [SocketUser:WebSocket]()

    /// 添加用户， 登录时使用
    func addChat(json:[String:Any], socket: WebSocket) {
        let user = jsonToModel(json: json)
        guard let n_user = user else { debugPrint("user empty"); return }
        
        _chats.updateValue(socket, forKey: n_user)
    }
    
    /// 移除用户， 登出时使用
    func removeChat(json:[String:Any]) {
        let user = jsonToModel(json: json)
        guard let n_user = user else { debugPrint("user empty"); return }
        
        _chats.removeValue(forKey: n_user)
    }
    
    /// 发送消息， 单聊
    func sendMessage(json:[String:Any], socket: WebSocket) {
        guard let message = json["message"] as? String, let to = json["to"] as? String, let uid = json["uid"] as? String else {
            debugPrint("send message error")
            return
        }
        //  根据消息中的to字段生成user模型
        let toUserSocket = SocketUser(_uid: to)
        
        //  从登陆用户中获取接收方的socket对象
        if let toSocket = _chats[toUserSocket] {
            let messageDic:[String:Any] = ["uid": uid, "message": message, "to": to]
            sendJSON(socket: toSocket, json: messageDic)
        }
    }
    
    /// 查找所有在线用户的uid
    func queryUserList(json:[String:Any], socket: WebSocket) {
        var userList:[[String:String]] = []
        for key in _chats.keys {
            userList.append(["uid": key.uid, "name": key.name])
        }
        
        //  发送所有在线用户的id给发消息方
        let messageDic = ["userList": userList]
        sendJSON(socket: socket, json: messageDic)
    }
}

//MARK: Room Methods
extension SocketManager {
    func creatRoom(json: [String:Any], socket: WebSocket) {
        SocketRoomManager.instance.creatRoom(json: json, socket: socket)
    }
    
    func inRoom(json: [String:Any], socket: WebSocket) {
        SocketRoomManager.instance.inRoom(json: json, socket: socket)
    }
    
    func outRoom(json: [String:Any], socket: WebSocket) {
        SocketRoomManager.instance.outRoom(json: json, socket: socket)
    }
    
    func queryRoomList(socket: WebSocket) {
        SocketRoomManager.instance.queryRoomList(socket: socket)
    }
    
    func groupChat(json: [String: Any], socket: WebSocket) {
        SocketRoomManager.instance.groupChat(json: json, socket: socket)
    }
}

//MARK: Private Methods
extension SocketManager {
    
    fileprivate func jsonToModel(json:[String:Any]) -> SocketUser? {
        do {
            let jsonUser = try SocketUser(json: json)
            return jsonUser
        } catch {
            debugPrint(error)
            return nil
        }
    }
    
    func sendJSON(socket:WebSocket, json:[String:Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let bytes = [UInt8](jsonData)
            socket.sendBinaryMessage(bytes: bytes, final: true, completion: {
                debugPrint("send message complete")
            })
        } catch {
            debugPrint(error)
        }
    }
}

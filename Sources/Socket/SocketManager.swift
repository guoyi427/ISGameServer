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
    
    var _chats = [String:WebSocket]()
    
    func addChat(json:[String:Any], socket: WebSocket) {
        guard let uid = json["uid"] as? String else {
            debugPrint("add chat error")
            return
        }
        _chats.updateValue(socket, forKey: uid)
    }
    
    func sendMessage(json:[String:Any], socket: WebSocket) {
        guard let message = json["message"] as? String, let to = json["to"] as? String, let uid = json["uid"] as? String else {
            debugPrint("send message error")
            return
        }
        
        if let toSocket = _chats[to] {
            let messageDic:[String:Any] = ["uid": uid, "message": message, "to": to]
            do {
                let jsonStr = try messageDic.jsonEncodedString()
                
                toSocket.sendStringMessage(string: jsonStr, final: true, completion: {
                    debugPrint("send message complete")
                })
            } catch {
                debugPrint(error)
            }
            
        }
    }
}

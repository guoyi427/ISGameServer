//
//  SocketHandle.swift
//  PerfectTemplate
//
//  Created by kokozu on 2017/4/19.
//
//

import Foundation
import PerfectWebSockets
import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

func chatHandler(data: [String:Any]) throws -> RequestHandler {
    return {
        request, response in
        WebSocketHandler(handlerProducer: { (s_request, protocols: [String]) -> WebSocketSessionHandler? in
            debugPrint("protocols \(protocols)")
            return ChatHandler()
        }).handleRequest(request: request, response: response)
    }
}

class ChatHandler: WebSocketSessionHandler {
    let socketProtocol: String? = "chat"
    
    func handleSession(request req: HTTPRequest, socket: WebSocket) {
        debugPrint("req \(req)  socket \(socket)")
        
        //  文本消息    仅测试字符串用
        socket.readStringMessage { (string, op, fin) in
            guard let string = string else {
                debugPrint("close1")
                socket.close()
                return
            }
            debugPrint("read msg \(string) op \(op) fin \(fin) address\(socket)")
            
            //  判断消息类型
            
            socket.sendStringMessage(string: "server send message", final: true, completion: { 
                debugPrint("server send message complete")
            })
            self.handleSession(request: req, socket: socket)
        }
        
        //  二进制消息
        socket.readBytesMessage { (bytes, op, fin) in
            guard let bytes = bytes else {
                debugPrint("close2")
                socket.close()
                return
            }
            
            // json 解析 bytes
            do {
                let jsonDic = try JSONSerialization.jsonObject(with: Data(bytes), options: [])
                
                guard let dic = jsonDic as? [String: Any] else {
                    return
                }
                
                guard let code = dic["code"] as? Int else {
                    debugPrint("json error")
                    return
                }
                
                //  判断消息类型
                if code == 10 {
                    //  login 
                    SocketManager.instance.addChat(json: dic, socket: socket)
                } else if code == 0 {
                    //  message
                    SocketManager.instance.sendMessage(json: dic, socket: socket)
                }
                self.handleSession(request: req, socket: socket)

            } catch {
                debugPrint(error)
                return
            }
        }
    }
}


enum UserError: Error {
    case failedToCreate
}

class User: Hashable {
    var uid: String
    var name: String
    
    init(json:[String: Any]) throws {
        guard let userID = json["uid"] as? String, let userName = json["name"] as? String else {
            throw UserError.failedToCreate
        }
        uid = userID
        name = userName
    }
    
    init() {
        uid = "0"
        name = ""
    }
    
    var hashValue: Int {
        return uid.hashValue
    }
    
    public static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}

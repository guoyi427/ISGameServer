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

/*
 code
 
 */
enum SocketCode:Int {
    case Login      = 10
    case Logout
    
    case Chat       = 100
    case Group
    case System
    
    case CreatRoom  = 200
    case InRoom
    case OutRoom
    case QueryRoomList
    
    case QueryUserList = 300
}

class ChatHandler: WebSocketSessionHandler {
    let socketProtocol: String? = "chat"
    
    func handleSession(request req: HTTPRequest, socket: WebSocket) {
        debugPrint("req \(req)  socket \(socket)")
        
        //  接收消息回调
        socket.readBytesMessage { (bytes, op, fin) in
            guard let bytes = bytes else {
                debugPrint("close")
                socket.close()
                return
            }
            
            do {
                let jsonDic = try JSONSerialization.jsonObject(with: Data(bytes), options: [])
                
                guard let dic = jsonDic as? [String: Any] else {
                    debugPrint("json error")
                    return
                }
                
                guard let codeRaw = dic["code"] as? SocketCode.RawValue, let code = SocketCode(rawValue: codeRaw) else {
                    debugPrint("socketCode error")
                    return
                }
                
                //  判断消息类型  根据消息类型发送消息
                switch code {
                case .Login:
                    SocketManager.instance.addChat(json: dic, socket: socket)
                    break
                case .Logout:
                    SocketManager.instance.removeChat(json: dic)
                    break
                case .Chat:
                    SocketManager.instance.sendMessage(json: dic, socket: socket)
                    break
                case .QueryUserList:
                    SocketManager.instance.queryUserList(json: dic, socket: socket)
                    break
                case .CreatRoom:
                    SocketManager.instance.creatRoom(json: dic, socket: socket)
                    break
                case .InRoom:
                    SocketManager.instance.inRoom(json: dic, socket: socket)
                    break
                case .OutRoom:
                    SocketManager.instance.outRoom(json: dic, socket: socket)
                    break
                case .QueryRoomList:
                    SocketManager.instance.queryRoomList(socket: socket)
                    break
                case .Group:
                    SocketManager.instance.groupChat(json: dic, socket: socket)
                    break
                default:
                    break
                }
                
                self.handleSession(request: req, socket: socket)
            } catch {
                debugPrint(error)
                return
            }
        }
    }
}

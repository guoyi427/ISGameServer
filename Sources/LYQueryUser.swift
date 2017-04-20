//
//  LYQueryUser.swift
//  PerfectTemplate
//
//  Created by 郭毅 on 2017/3/31.
//
//

import Foundation
import PerfectHTTP

class LYQueryUser {
    static func queryUserHandler(data: [String: Any]) throws -> RequestHandler {
        return {
            request, response in
            let para = request.params()
            print("para = \(para)")
            
            let user = LYTest.shared().queryUser(uid: "10001")
            
            response.setHeader(.contentType, value: "text/json;charset='utf8")
            if let tempUser = user as? [String] {
                var jsonDic = [String: String]()
                jsonDic.updateValue(tempUser[0], forKey: "id")
                jsonDic.updateValue(tempUser[1], forKey: "uid")
                jsonDic.updateValue(tempUser[2], forKey: "name")
                jsonDic.updateValue(tempUser[3], forKey: "mobile")
                jsonDic.updateValue(tempUser[5], forKey: "gender")
                jsonDic.updateValue(tempUser[6], forKey: "headImage")

                let jsonStr = try! jsonDic.jsonEncodedString()
                response.setBody(string: jsonStr)
                
            }
            response.completed()
        }
    }
}

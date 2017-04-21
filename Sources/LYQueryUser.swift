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
    
    static func login_wx_user(data:[String:Any]) throws -> RequestHandler {
        return {
            request, response in
            
            let wx_id = request.param(name: "wx_id")
            let name = request.param(name: "name")
            
            guard let n_wx_id = wx_id else {
                let msg = "缺少参数，wx_id"
                response.appendBody(string: msg)
                response.completed()
                return
            }
            
            let userInfoDic:[String:String] = MySQLManager.instance.query_wx_user(wx_id: n_wx_id)
            //  查询是否存在此 wx_id
            if userInfoDic.count > 0 {
                //  如果存在 更新token
                do {
                    let bodyStr = try userInfoDic.jsonEncodedString()
                    response.appendBody(string: bodyStr)
                } catch {
                    print(error)
                }
                
                response.completed()
            } else {
                //  如果不存在wx_id 此时接口为登陆 新增一个
                var n_name:String = ""
                if name != nil {
                    n_name = name!
                }
                let insertResult = MySQLManager.instance.insert_wx_user(wx_id: n_wx_id, name: n_name)
                guard insertResult.succes else {
                    let msg = "插入用户失败"
                    debugPrint(msg)
                    response.appendBody(string: msg)
                    response.completed()
                    return
                }
                
                //  登陆成功
                let bodyDic = ["token":insertResult.token]
                do {
                    let bodyStr = try bodyDic.jsonEncodedString()
                    response.appendBody(string: bodyStr)
                } catch {
                    let msg = "解析错误"
                    debugPrint(msg)
                    response.appendBody(string: msg)
                }
                response.completed()
            }
        }
    }
}

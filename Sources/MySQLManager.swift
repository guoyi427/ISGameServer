//
//  MySQLManager.swift
//  PerfectTemplate
//
//  Created by kokozu on 2017/4/21.
//
//

import Foundation
import MySQL

class MySQLManager {
    fileprivate let Host = "127.0.0.1"
    fileprivate let Account = "guoyi"
    fileprivate let Password = "gy1111"
    fileprivate let Port:UInt32 = 3306
    fileprivate let UserDBName = "User"
    
    static let instance = MySQLManager()
    
    fileprivate var _mysql:MySQL
    
    init() {
        _mysql = MySQL()
        connect()
    }
    
    deinit {
        disConnect()
    }
    
    func connect() {
        guard _mysql.connect(host: Host, user: Account, password: Password, port:Port) else {
            print("MySQL Connect Failed")
            return
        }
        
    }
    
    func disConnect() {
        _mysql.close()
    }
    
}

extension MySQLManager {
    func calculateToken(uid:String) -> String {
        let token = uid
        //  更新数据库中的token
        
        return token
    }
}

//MARK: Login Methods
extension MySQLManager {
    //  表结构   uid, wx_id, mobile, name, account, password, token
    
    /// 查询微信id对应的用户信息
    ///
    /// - Parameter wx_id: 微信id
    /// - Returns: 返回 uid, token
    func query_wx_user(wx_id:String) -> [String:String] {
        
        var resultDic:[String:String] = [:]
        
        if let result = query(tableName: "user_account", find: "uid, token, name", wherePara: "wx_id='\(wx_id)'").mysqlResult {
            result.forEachRow(callback: { (row) in
                resultDic["uid"] = row[0]
                resultDic["token"] = row[1]
                resultDic["name"] = row[2]
            })
        }
        
        return resultDic
    }
    
    func insert_wx_user(wx_id:String, name:String) -> (succes:Bool, token:String, uid: String, name: String) {
        var para = ["name":name, "wx_id":wx_id]
        
        //  max uid
        let sql = "select MAX(uid) from user_account"
        
        var max_uid = "10000"
        
        if let max_uid_result = mysqlStatement(sql: sql).mysqlResult {
            max_uid_result.forEachRow { (row) in
                guard let uidString = row[0] else {
                    let msg = "查询最大id失败"
                    debugPrint(msg)
                    return
                }
                max_uid = uidString
            }
        }
        
        
        guard let max_uid_int = Int64(max_uid), max_uid.characters.count > 0 else {
            let msg = "max id error"
            debugPrint(msg)
            return (false, "", "", "")
        }
        
        let uid = String(max_uid_int+1)
        let token = calculateToken(uid: uid)
        para["uid"] = uid
        para["token"] = token
        
        return (insert(tableName: "user_account", para: para).success, token, uid, name)
    }
}

//MARK: 数据库基础方法
extension MySQLManager {
    func mysqlStatement(sql:String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        guard _mysql.selectDatabase(named: UserDBName) else {
            let msg = "未找到\(UserDBName)数据库"
            print(msg)
            return (false, nil, msg)
        }
        
        guard _mysql.query(statement: sql) else {
            let msg = "SQL 失败：\(sql)"
            print(msg)
            return (false, nil, msg)
        }
        
        let msg = "SQL 成功:\(sql)"
        debugPrint(msg)
        return (true, _mysql.storeResults(), msg)
    }
    
    func insert(tableName: String, para: [String:String]) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        var left: String = "insert into \(tableName) "
        var right: String = " values "
        
        var fristAppend = true
        
        for key in para.keys {
            if fristAppend {
                left.append("(\(key)")
                right.append("('\(para[key]!)'")
            } else {
                left.append(", \(key)")
                right.append(", '\(para[key]!)'")
            }
            fristAppend = false
        }
        left.append(")")
        right.append(")")
        
        let sqlStr = left + right
        
        return mysqlStatement(sql: sqlStr)
    }
    
    func query(tableName: String, find: String, wherePara: String) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        let sqlStr = "select \(find) from \(tableName) where \(wherePara)"
        
        return mysqlStatement(sql: sqlStr)
    }
    
    func update(tableName: String, para: [String:String], wherePara: [String:String]?) -> (success: Bool, mysqlResult: MySQL.Results?, errorMsg: String) {
        var left:String = "update \(tableName) set "
        var right:String = ""
        
        var fristAppendLeft = true
        for key in para.keys {
            if fristAppendLeft {
                left.append("\(key) = '\(para[key]!)'")
            } else {
                left.append(", \(key) = '\(para[key]!)'")
            }
            fristAppendLeft = false
        }
        
        var fristAppendRight = true
        if let n_where = wherePara {
            right.append("where")
            for key in n_where.keys {
                if fristAppendRight {
                    right.append("\(key) = '\(para[key]!)'")
                } else {
                    right.append(", \(key) = '\(para[key]!)'")
                }
                fristAppendRight = false
            }
        }
        return mysqlStatement(sql: left + right)
    }
}

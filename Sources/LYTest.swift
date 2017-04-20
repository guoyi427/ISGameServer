//
//  LYTest.swift
//  PerfectTemplate
//
//  Created by 郭毅 on 2017/3/30.
//
//

import Foundation
import MySQL

//  数据库管理

class LYTest {
    
    static let instance = LYTest()
    
    fileprivate let _mysql = MySQL()
    fileprivate let _host = "127.0.0.1"
    fileprivate let _user = "guoyi"
    fileprivate let _password = "gy1111"
    
    static func shared() -> LYTest {
        return instance
    }
    
    func connect() -> Bool {
        
        let isConnected = _mysql.connect(host: _host, user: _user, password: _password)
        
        return isConnected
    }
    
    func disconnect() {
        _mysql.close()
    }
    
    func queryUser(uid: String) -> [String?]? {
        
        guard _mysql.connect(host: _host, user: _user, password: _password, db: "test") else {
            print("connect mysql failed")
            return nil
        }
        
        defer {
            _mysql.close()
        }
        
        let mysqlCommand = "select * from test_user where uid = \(uid)"
        
        guard _mysql.query(statement: mysqlCommand) else {
            print("query failed code = \(_mysql.errorCode()), message = \(_mysql.errorMessage())")
            return nil
        }
        
        let results = _mysql.storeResults()
        
        var rowsList = [String]()
        
    
        while let row = results?.next() {
            if let element = row as? [String] {
                rowsList.append(contentsOf: element)
            }
        }
        
        results?.close()
        
        disconnect()
        
        return rowsList
    }
    
}

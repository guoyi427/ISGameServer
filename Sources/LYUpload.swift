//
//  LYUpload.swift
//  PerfectTemplate
//
//  Created by 郭毅 on 2017/4/3.
//
//

import PerfectHTTP
import PerfectLib

class LYUpload {
    
    static func handler(data:[String:Any]) throws -> RequestHandler {
        return { (request:HTTPRequest, response:HTTPResponse) in
            
            response.setHeader(.contentType, value: "application/json")
            
            var jsonDic:[String:Any] = [:]
            
            if let uploads = request.postFileUploads, uploads.count > 0 {

                
                let rootPath = request.documentRoot
                let fileDir = Dir(rootPath+"/Files/Image")
                
                do {
                    try fileDir.create()
                } catch {
                    print(error)
                }
                
                var pathList:[String] = []
                
                
                for upload in uploads {
                    let tempFile = upload.file
                    do {
                        let newFile = try tempFile?.moveTo(path: fileDir.path + upload.fileName, overWrite: true)
                        if let file = newFile {
                            let resultPath = "/Image/\(upload.fileName)"
                            print(file.path, resultPath)
                            pathList.append(resultPath)
                        }
                    } catch {
                        print(error)
                    }
                }
                
                //  返回数据
                jsonDic.updateValue(pathList, forKey: "image")
            }
            
            var jsonStr = ""
            
            do {
                jsonStr = try jsonDic.jsonEncodedString()
            } catch {
                jsonStr = "error"
            }
            
            response.appendBody(string: jsonStr)
            response.completed()
        }
    }
}

//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import MySQL

// An example request handler.
// This 'handler' function can be referenced directly in the configuration below.
func handler(data: [String:Any]) throws -> RequestHandler {
	return {
		request, response in
		// Respond with a simple message.
		response.setHeader(.contentType, value: "text/html")
		response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
		// Ensure that response.completed() is called when your processing is done.
		response.completed()
	}
}

let customHandler = {
    (request: HTTPRequest, response: HTTPResponse) in
    response.setHeader(.contentType, value: "application/json")
    
    var jsonString = ""
    
    do {
        jsonString = try "hello world!".jsonEncodedString()
    } catch {
        
    }
    
    debugPrint(jsonString)
    response.appendBody(string: jsonString)
    response.completed()
}

// Configuration data for two example servers.
// This example configuration shows how to launch one or more servers 
// using a configuration dictionary.

let port1 = 8080, port2 = 8181

let confData = [
	"servers": [
		// Configuration data for one server which:
		//	* Serves the hello world message at <host>:<port>/
		//	* Serves static files out of the "./webroot"
		//		directory (which must be located in the current working directory).
		//	* Performs content compression on outgoing data when appropriate.
		[
			"name":"localhost",
			"port":port1,
			"routes":[
				["method":"get", "uri":"/", "handler":handler],
				["method":"get", "uri":"/wx_login", "handler":LYQueryUser.login_wx_user],
				["method":"post", "uri":"/upload", "handler":LYUpload.handler],
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				 "documentRoot":"./webroot/",
				 "allowResponseFilters":true]
			],
			"filters":[
				[
				"type":"response",
				"priority":"high",
				"name":PerfectHTTPServer.HTTPFilter.contentCompression,
				]
			]
		],
		// Configuration data for another server which:
		//	* Redirects all traffic back to the first server.
		[
			"name":"localhost",
			"port":port2,
			"routes":[
				["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.redirect,
				 "base":"http://localhost:\(port1)"]
			]
		],
		[
            "name":"chat",
            "port":8282,
            "routes":[
                ["method":"get", "uri":"/chat", "handler":chatHandler]
            ],
            "filters":[
                [
                    "type":"response",
                    "priority":"high",
                    "name":PerfectHTTPServer.HTTPFilter.contentCompression,
                    ]
            ]
        ],
	]
]

let server = HTTPServer()

var _routes = Routes()
_routes.add(method: .get, uri: "/", handler: customHandler)
_routes.add(method: .post, uri: "/", handler: customHandler)
//_routes.add(method: .get, uri: "/upload", handler: LYUpload.gyHandler)
//_routes.add(method: .post, uri: "/upload", handler: LYUpload.gyHandler)

server.addRoutes(_routes)
server.serverPort = 8080
server.documentRoot = "./webroot/"

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}


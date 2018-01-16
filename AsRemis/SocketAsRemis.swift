//
//  SocketAsRemis.swift
//  IDE
//
//  Created by Luis Fernando Bustos Ramírez on 12/7/17.
//  Copyright © 2017 Apreciasoft. All rights reserved.
//

import UIKit
import SocketIO

class SocketAsRemis: NSObject {
    private var manager = SocketManager(socketURL: URL(string: "\(GlobalMembers().socketProtocol)://\(GlobalMembers().socketIp)")!)
    private var MY_EVENT = "message";
    
    func createSocketConnectionWith(user userId:NSNumber){
        let dir = "\(GlobalMembers().socketProtocol)://\(GlobalMembers().socketIp):\(GlobalMembers().socketPort)?idUser=\(userId)&uri=\(GlobalMembers().socketInstance)"
        print("socket \(dir)")
        manager = SocketManager(socketURL: URL(string: dir)!, config: [.log(true), .compress])
        //let socket = manager.defaultSocket
        manager.defaultSocket.on(clientEvent: .connect) {data, ack in
            print("socket connected data: \(data)\n")
            print("socket connected ack: \(ack)\n")
            print("socket connected session id: \(self.manager.defaultSocket.sid)\n")
            
            var driverId = NSNumber.init(value: 0)
            if SingletonsObject.sharedInstance.userSelected?.user?.idDriver != nil{
                driverId = (SingletonsObject.sharedInstance.userSelected?.user?.idDriver)!
            }
            
            if driverId.intValue > 0{
                let token = TokenEntity.init(tokenFB: "", idUser: (SingletonsObject.sharedInstance.userSelected?.user?.idUser)!, idDriver: driverId, latVersionApp: SingletonsObject.sharedInstance.appCurrentVersion as String, idSocketMap: self.manager.defaultSocket.sid)
                let http = Http.init()
                http.getToken(token, completion: { (isValidToken) -> Void in
                    if isValidToken{
                       print("driver connected")
                    }else{
                        print("error in connect driver")
                    }
                })
            }
        }
        manager.defaultSocket.on(clientEvent: .reconnect){data,ack in
            print("socket reconnect: \(data)\n")
        }
        manager.defaultSocket.on(clientEvent: .statusChange){data,ack in
            print("socket \nStatus change: \(data)\n")
        }
        manager.defaultSocket.on(clientEvent: .disconnect){ data,ack in
            print("socket disconnected: \(data)\n")
        }
        manager.defaultSocket.on(clientEvent: .error){ data, ack in
            print("socket error: \(data)\n")
        }
        manager.defaultSocket.on(MY_EVENT) {data, ack in
             print("socket message: \(data)\n")
        }
        manager.defaultSocket.connect()
        
    }
    
    
}


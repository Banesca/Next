//
//  SocketAsRemis.swift
//  IDE
//
//  Created by Luis Fernando Bustos Ramírez on 12/7/17.
//  Copyright © 2017 Apreciasoft. All rights reserved.
//

import UIKit
import SwiftSocket
import SocketIO

class SocketAsRemis: NSObject {
    
    func createSocketConnectionWith(user userId:NSNumber){
        let dir = "\(GlobalMembers().masterIp):3300?idUser=\(userId)&uri=developer"
        let socket = SocketIOClient(socketURL: URL(string: dir)!, config: [.log(true), .compress])
        
        
        // Called on every event
        socket.onAny {
            print("got event: \($0.event) with items \($0.items ?? [])")
            
        }
        
        // Socket Events
        socket.on("connect") {data, ack in
            print("socket connected")
            
            // Sending messages
            socket.emit("testEcho")
            
            socket.emit("testObject", [
                "data": true
                ])
            
            // Sending multiple items per message
            socket.emit("multTest", [1], 1.4, 1, "true",
                        true, ["test": "foo"], "bar")
        }

        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on("currentAmount") {data, ack in
            if let cur = data[0] as? Double {
                socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                    socket.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
        }
        
        socket.connect()
    }
    
    
}


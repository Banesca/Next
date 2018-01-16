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
    
    func createSocketConnectionWith(user userId:NSNumber){
        let dir = "\(GlobalMembers().masterIp):\(GlobalMembers().socketPort)?idUser=\(userId)&uri=next"
        let manager = SocketManager(socketURL: URL(string: dir)!, config: [.log(true), .compress])
        let socket = manager.defaultSocket
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on("currentAmount") {data, ack in
            guard let cur = data[0] as? Double else { return }
            
            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                socket.emit("update", ["amount": cur + 2.50])
            }
            
            ack.with("Got your currentAmount", "dude")
        }
        
        
        socket.connect()
    }
    
    
}


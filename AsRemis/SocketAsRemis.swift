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
        let dir = "\(GlobalMembers().socketProtocol)://\(GlobalMembers().socketIp):\(GlobalMembers().socketPort)?idUser=\(userId)&uri=\(GlobalMembers().socketInstance)"
        print("socket \(dir)")
        let manager = SocketManager(socketURL: URL(string: dir)!, config: [.log(true), .compress])
        let socket = manager.defaultSocket
        
        
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        
        socket.on(clientEvent: .ping){data,ack in
            print("socket ping")
        }
        socket.on(clientEvent: .pong){data,ack in
            print("socket pong")
        }
        socket.on(clientEvent: .reconnect){data,ack in
            print("socket reconnect")
        }
        socket.on(clientEvent: .statusChange){data,ack in
            print("socket \nStatus change: \(data)\n")
        }
        
        socket.on(clientEvent: .disconnect){ data,ack in
            print("socket disconnected")
        }
        socket.on(clientEvent: .error){ data, ack in
            print("socket error")
        }
        
        socket.on("message") {data, ack in
            guard let cur = data[0] as? Double else { return }
            
            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                socket.emit("update", ["amount": cur + 2.50])
            }
            
            ack.with("Got your currentAmount", "dude")
        }
        
        
        socket.connect()
    }
    
    
}


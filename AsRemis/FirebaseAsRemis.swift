//
//  FirebaseAsRemis.swift
//  IDE
//
//  Created by Luis Fernando Bustos Ramírez on 1/7/18.
//  Copyright © 2018 Apreciasoft. All rights reserved.
//

import UIKit

final class FirebaseAsRemis: NSObject {
    
    static let sharedInstance = FirebaseAsRemis()
    var timer = Timer()
    
    private override init() {super.init()}
    
    func checkFoNewTrips(){
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.newTripAvailable), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    @objc private func newTripAvailable() {
        let http = Http.init()
        guard let idDriver = SingletonsObject.sharedInstance.userSelected?.user else{
            return
        }
        http.getCurrentTravelByIdDriver(idDriver.idDriver!, completion: { (trip) -> Void in
            if trip != nil{
                SingletonsObject.sharedInstance.currentTrip = trip
                NotificationCenter.default.post(name: Notification.Name(showTripRequestNotification),object: nil)
            }
        })
    }
}

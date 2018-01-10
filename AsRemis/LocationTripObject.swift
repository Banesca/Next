//
//  LocationTripObject.swift
//  IDE
//
//  Created by Luis Fernando Bustos Ramírez on 1/7/18.
//  Copyright © 2018 Apreciasoft. All rights reserved.
//

import UIKit
import CoreLocation

final class LocationTripObject: NSObject {

    static let sharedInstance = LocationTripObject()
    var userPosition: CLLocation?
    var startTripLocation: CLLocation?
    var tripIsWait = 0
    var isReturn = 0
    var totalDistance = 0.0
    var distancesInReturn = 0.0
    var distanceNormal = 0.0
    var waitTime = 0.0
    var totalCost = 0.0
    var timeCost = 0.0
    var distanceCost = 0.0
    var timer = Timer()
    var timerws = Timer()
    
    private override init() {super.init()}
    
    func startSendLocation(){
        distancesInReturn = 0.0
        distanceNormal = 0.0
        totalCost = 0.0
        waitTime = 0.0
        startTripLocation = userPosition
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updatePrice), userInfo: nil, repeats: true)
        timer.fire()
        timerws = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        timerws.fire()
    }
    
    func stopSendLocation(){
        timer.invalidate()
        timerws.invalidate()
    }
    
    @objc func update() {
        let distance = NSNumber(value: (distancesInReturn+distanceNormal))
        let idUser = SingletonsObject.sharedInstance.userSelected?.user?.idUser
        let idTravelKf = SingletonsObject.sharedInstance.currentTrip?.idTravel
        let driverKf = SingletonsObject.sharedInstance.currentTrip?.idUserDriver
        let idClientKf = SingletonsObject.sharedInstance.currentTrip?.idClientKf
        let travelLocation = TravelLocationEntity(idUser: (idUser)!,
                                                  idTravelKf: idTravelKf!,
                                                  location: (userPosition?.description)!,
                                                  longLocation: "\(userPosition?.coordinate.longitude ?? 0)",
                                                  latLocation: "\(userPosition?.coordinate.latitude ?? 0)",
                                                  idDriverKf: driverKf!,
                                                  idVeichleAsigned: 0,
                                                  idClientKf: idClientKf!,
                                                  distanceSave: distance)
        let http = Http.init()
        http.sendPosition(travelLocation, completion: {(RemisSocketInfoEntity) -> Void in })
    }
    
    @objc func updatePrice() {
        checkCurrentDistance()
        checkCurrentTime()
    }
    
    func checkCurrentDistance(){
        let distance = (userPosition?.distance(from: startTripLocation!))!/1000
        startTripLocation = userPosition
        if isReturn == 1{
            distancesInReturn = distancesInReturn + distance
        }else{
            distanceNormal = distanceNormal + distance
        }
    }
    
    func checkCurrentTime(){
        if tripIsWait == 1{
            waitTime = waitTime + 0.5
        }
        let costPerMinute = Double(SingletonsObject.sharedInstance.userSelected?.params?[4].value ?? "0.0")!
        timeCost = waitTime/60 * costPerMinute
    }
    
    func checkTotalCost(){
        totalDistance = distanceNormal + distancesInReturn
        if SingletonsObject.sharedInstance.currentTrip?.isTravelComany == 1 || (SingletonsObject.sharedInstance.currentTrip?.priceDitanceCompany?.doubleValue)! == 0{
            let currentCost = Double((SingletonsObject.sharedInstance.userSelected?.params?.first?.value)!)
            distanceCost = totalDistance * currentCost!
        }else{
            let costReturn = distancesInReturn * (SingletonsObject.sharedInstance.currentTrip?.priceReturn?.doubleValue)!
            let costNormal = distanceNormal *  (SingletonsObject.sharedInstance.currentTrip?.priceDitanceCompany?.doubleValue)!
            distanceCost = costNormal + costReturn
        }
        
        totalCost = distanceCost + timeCost
        
        if totalCost < (SingletonsObject.sharedInstance.currentTrip?.priceMinTravel?.doubleValue)!{
            totalCost = (SingletonsObject.sharedInstance.currentTrip?.priceMinTravel?.doubleValue)!
        }
        
        let paramMinCost = Double(SingletonsObject.sharedInstance.userSelected?.params?[16].value ?? "0.0")!
        if totalCost < paramMinCost{
            totalCost = paramMinCost
        }
    }
}

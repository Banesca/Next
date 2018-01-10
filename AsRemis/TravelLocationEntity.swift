//
//  TravelLocationEntity.swift
//  IDE
//
//  Created by Luis Fernando Bustos Ramírez on 02/01/18.
//  Copyright © 2018 Apreciasoft. All rights reserved.
//

import UIKit

class TravelLocationEntity: NSObject {

    var idUser: NSNumber?
    var idTravelKf: NSNumber?
    var idDriverKf: NSNumber?
    var idVeichleAsigned: NSNumber?
    var idClientKf: NSNumber?
    var distanceSave: NSNumber?
    var totalAmount: NSNumber?
    var location: String?
    var longLocation: String?
    var latLocation: String?
    var distanceGps: NSNumber?
    var distanceGpsLabel: String?
    var amounttoll: NSNumber?
    var amountParking: NSNumber?
    var amountTiemeSlepp: NSNumber?
    var timeSleppGps: String?
    var idPaymentFormKf: NSNumber?
    
    init(idUser: NSNumber, idTravelKf: NSNumber, location: String, longLocation: String, latLocation: String, idDriverKf: NSNumber, idVeichleAsigned: NSNumber, idClientKf: NSNumber, distanceSave:NSNumber){
        self.idUser = idUser
        self.idTravelKf = idTravelKf
        self.location = location
        self.longLocation = longLocation
        self.latLocation = latLocation
        self.idDriverKf = idDriverKf
        self.idVeichleAsigned = idVeichleAsigned
        self.idClientKf = idClientKf
        self.distanceSave = distanceSave
    }
    
    init(idTravelKf: NSNumber, totalAmount: NSNumber, distanceGps: NSNumber, distanceGpsLabel: String, location: String, longLocation: String, latLocation: String, amounttoll: NSNumber, amountParking: NSNumber, amountTiemeSlepp: NSNumber, timeSleppGps: String, idPaymentFormKf: NSNumber){
        self.idTravelKf = idTravelKf
        self.totalAmount = totalAmount
        self.distanceGps = distanceGps
        self.distanceGpsLabel = distanceGpsLabel
        self.location = location
        self.longLocation = longLocation
        self.latLocation = latLocation
        self.amounttoll = amounttoll
        self.amountParking = amountParking
        self.amountTiemeSlepp = amountTiemeSlepp
        self.timeSleppGps = timeSleppGps
        self.idPaymentFormKf = idPaymentFormKf
    }
    
    init(jsonData: [String: Any]){
        print(jsonData)
        if let tempVar = jsonData["idUser"] as? String{
            idUser = NSNumber(value: Int(tempVar)!)
        }
        if let tempVar = jsonData["idTravelKf"] as? String{
            idTravelKf = NSNumber(value: Int(tempVar)!)
        }
        if let tempVar = jsonData["idDriverKf"] as? String{
            idDriverKf = NSNumber(value: Int(tempVar)!)
        }
        if let tempVar = jsonData["idVeichleAsigned"] as? String{
            idVeichleAsigned = NSNumber(value: Int(tempVar)!)
        }
        if let tempVar = jsonData["idClientKf"] as? String{
            idClientKf = NSNumber(value: Int(tempVar)!)
        }
        if let tempVar = jsonData["distanceSave"] as? String{
            distanceSave = NSNumber(value: Int(tempVar)!)
        }
        if let tempVar = jsonData["totalAmount"] as? String{
            totalAmount = NSNumber(value: Int(tempVar)!)
        }
        location = jsonData["location"] as? String
        longLocation = jsonData["longLocation"] as? String
        latLocation = jsonData["latLocation"] as? String
        if let tempVar = jsonData["distanceGps"] as? String{
            distanceGps = NSNumber(value: Int(tempVar)!)
        }
        distanceGpsLabel = jsonData["distanceGpsLabel"] as? String
        if let tempVar = jsonData["amounttoll"] as? String{
            amounttoll = NSNumber(value: Int(tempVar)!)
        }
        if let tempVar = jsonData["amountParking"] as? String{
            amountParking = NSNumber(value: Int(tempVar)!)
        }
        if let tempVar = jsonData["amountTiemeSlepp"] as? String{
            amountTiemeSlepp = NSNumber(value: Int(tempVar)!)
        }
        timeSleppGps = jsonData["timeSleppGps"] as? String
        if let tempVar = jsonData["idPaymentFormKf"] as? String{
            idPaymentFormKf = NSNumber(value: Int(tempVar)!)
        }
    }
    
    func toJSON() -> [String: Any]{
        return [
            "idUser": idUser as Any,
            "idTravelKf": idTravelKf as Any,
            "idDriverKf": idDriverKf as Any,
            "idVeichleAsigned": idVeichleAsigned as Any,
            "idClientKf": idClientKf as Any,
            "distanceSave": distanceSave as Any,
            "totalAmount": totalAmount as Any,
            "location": location as Any,
            "longLocation": longLocation as Any,
            "latLocation": latLocation as Any,
            "distanceGps": distanceGps as Any,
            "distanceGpsLabel": distanceGpsLabel as Any,
            "amounttoll": amounttoll as Any,
            "amountParking": amountParking as Any,
            "amountTiemeSlepp": amountTiemeSlepp as Any,
            "timeSleppGps": timeSleppGps as Any,
            "idPaymentFormKf": idPaymentFormKf as Any
        ]
    }
}

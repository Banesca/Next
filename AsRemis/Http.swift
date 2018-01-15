//
//  Http.swift
//  AsRemis
//
//  Created by Jorge Gutierrez on 29/9/17.
//  Copyright © 2017 Apreciasoft. All rights reserved.
//

import Foundation
import Alamofire


// MARK:LOGIN
class Http {
    
    func loginUser(_ user:UserEntity, completion:@escaping (UserFullEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("auth")
        let jsonUser = ["user":user.toJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            guard let dataJson = json?["response"] as? [String: Any] else {
                print("Malformed data received from loginUser response service")
                completion(nil)
                return
            }
            
            guard let userJson = dataJson["user"] as? [String: Any] else {
                print("Malformed data received from loginUser user service")
                completion(nil)
                return
            }
            
            let userResponse = UserEntity(jsonData: userJson)
            let userFull = UserFullEntity(withUser: userResponse)
            userFull.driverInactive = (dataJson["driverInactive"] as? NSNumber) ?? 0
            
            if let driverJson = dataJson["driver"] as? [String: Any]{
                let driverResponse = UserProfileEntity(driverData: driverJson)
                userFull.driver = driverResponse
            }
            
            if let clientJson = dataJson["client"] as? [String: Any]{
                let clientResponse = UserProfileEntity(clientData: clientJson)
                userFull.client = clientResponse
            }
            
            if let paramJson = dataJson["param"] as? [[String: Any]] {
                var paramsResponse = [ParamEntity]()
                for param in paramJson{
                    let paramResponse = ParamEntity(jsonData: param)
                    paramsResponse.append(paramResponse)
                }
                userFull.params = paramsResponse
            }
            
            completion(userFull)
        }
    }
    
    func updateClientLiteMobil(_ profile:UserProfileEntity, completion:@escaping (UserProfileEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("auth/updateClientLiteMobil")
        let jsonClient = ["client":profile.toClientJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonClient, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //print(response.result.value as Any)
            
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from updateClientLiteMobil service")
                    completion(nil)
                    return
            }
            let userResponse = UserProfileEntity.init(clientData: json!)
            completion(userResponse)
        }
    }
    
}

// MARK: SETTINGS
extension Http{
    
    func checkVersion(_ version: String, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("auth/checkVersion/\(version)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //print(response.result.value as Any)   // result of response serialization
            
            guard let jsonValue = response.result.value as? NSNumber else{
                print("Nil data received from checkVersion service")
                completion(false)
                return
            }
            
            completion(jsonValue.boolValue)
        }
    }
    
    func failReport(_ report:ReporteEntity, completion:@escaping (ReporteEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("support/add")
        let jsonUser = ["falla":report.toJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from failReport service")
                    completion(nil)
                    return
            }
            let report = ReporteEntity.init(jsonData: json!)
            completion(report)
        }
        
    }
    
    func getToken(_ token:TokenEntity, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("auth/token")
        let jsonUser = ["token":token.toJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            guard let jsonValue = response.result.value as? NSNumber else{
                print("Nil data received from getToken service")
                completion(false)
                return
            }
            completion(jsonValue.boolValue)
        }
    }
    
}

// MARK: NOTIFICATIONS
extension Http{
    
    func getNotification(_ notificationId: String, completion:@escaping ([NotificationEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("notifications/find/\(notificationId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            var notifications = [NotificationEntity]()
            if dataJson != nil{
                for entitieJson in dataJson!{
                    let entity = NotificationEntity.init(jsonData: entitieJson as! [String : Any])
                    notifications.append(entity)
                }
                completion(notifications)
            }else{
                completion(nil)
            }
            
            
        }
    }
    
    func readNotification(Id notificationId:NSNumber, userId:NSNumber, completion:@escaping ([NotificationEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("notifications/read/\(notificationId)/\(userId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            guard let dataJson = json?["response"] as? [String: Any] else {
                print("Malformed data received from loginUser response service")
                completion(nil)
                return
            }
            
            var notifications = [NotificationEntity]()
            if let entitiesJson = dataJson["notification"] as? [[String: Any]] {
                for entitieJson in entitiesJson{
                    let entity = NotificationEntity.init(jsonData: entitieJson)
                    notifications.append(entity)
                }
            }
            
            completion(notifications)
        }
    }
    
}

// MARK: TRAVEL
extension Http{
    func addTravel(_ token:TravelEntity, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/add")
        
        let jsonUser = ["travel" : token.toTripJson()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // URL response
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from loginUser service")
                    completion(false)
                    return
            }
            
            completion(true)
            
        }
    }
    
    func travelsByIdUser(_ userId: String, completion:@escaping ([InfoTravelEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/travelsByIdUser/\(userId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            var travelList = [InfoTravelEntity]()
            if dataJson != nil{
                for entitieJson in dataJson!{
                    let entity = InfoTravelEntity.init(travelData: entitieJson as! [String : Any])
                    travelList.append(entity)
                }
                
                completion(travelList)
            }else{
                completion(nil)
            }
        }
    }
    
    
    
    func sendPosition(_ travelLocation:TravelLocationEntity, completion:@escaping (RemisSocketInfoEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/sendPosition")
        let jsonTravel = ["travel":travelLocation.toJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonTravel, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //print(response.response as Any) // URL response
            //print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from sendPosition service")
                    completion(nil)
                    return
            }
            
            guard let dataJson = json?["response"] as? [String: Any] else {
                print("Malformed data received from sendPosition response service")
                completion(nil)
                return
            }
            
            let remisSocket = RemisSocketInfoEntity()
            
            if let paramJson = dataJson["listNotification"] as? [[String: Any]] {
                var notifications = [NotificationEntity]()
                for notif in paramJson{
                    let paramResponse = NotificationEntity(jsonData: notif)
                    notifications.append(paramResponse)
                }
                remisSocket.listNotification = notifications
            }
            
            if let paramJson = dataJson["listReservations"] as? [[String: Any]] {
                var travels = [InfoTravelEntity]()
                for trip in paramJson{
                    let paramResponse = InfoTravelEntity(travelData: trip)
                    travels.append(paramResponse)
                }
                remisSocket.listReservations = travels
            }
            
            completion(remisSocket)
        }
    }
    
    func infoTravelByDriver(_ token:TokenEntity, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/infoTravelByDriver")
        let jsonUser = ["token":token.toJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // URL response
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from loginUser service")
                    completion(false)
                    return
            }
            
        }
    }
    
    func isRoundTrip(Id tripId:NSNumber, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/isRoundTrip/\(tripId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let jsonValue = response.result.value as? NSNumber else{
                print("Nil data received from loginUser service")
                completion(false)
                return
            }
            
            completion(jsonValue.boolValue)
        }
    }
    
    func isWait(Id waitTd:NSNumber, value:String, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/isWait/\(waitTd)/\(value)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let jsonValue = response.result.value as? NSNumber else{
                print("Nil data received from isWait service")
                completion(false)
                return
            }
            
            completion(jsonValue.boolValue)
        }
    }
    
    func finishMobil(_ travel:TravelLocationEntity, completion:@escaping (InfoTravelEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/finishMobil")
        let jsonUser = ["travel":travel.toJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //print(response.response as Any) // URL response
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from finishMobil service")
                    completion(nil)
                    return
            }
            if (json?.count)! < 3{
                completion(nil)
            }else{
                let travelEntity = InfoTravelEntity.init(travelData: json!)
                completion(travelEntity)
            }
        }
    }
    
    func preFinishMobil(_ token:TravelLocationEntity, completion:@escaping (InfoTravelEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/preFinishMobil")
        let jsonUser = ["token":token.toJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // URL response
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from getReservations service")
                    completion(nil)
                    return
            }
            if (json?.count)! < 3{
                completion(nil)
            }else{
                let travelEntity = InfoTravelEntity.init(travelData: json!)
                completion(travelEntity)
            }
        }
    }
    
    func accept(Id travelId:NSNumber, completion:@escaping (InfoTravelEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/accept/\(travelId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // URL response
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from getReservations service")
                    completion(nil)
                    return
            }
            if (json?.count)! < 3{
                completion(nil)
            }else{
                let travelEntity = InfoTravelEntity.init(travelData: json!)
                completion(travelEntity)
            }
        }
    }
    
    func refuse(Id travelId:NSNumber, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/refuse/\(travelId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // URL response
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from loginUser service")
                    completion(false)
                    return
            }
            
        }
    }
    
    func initTrip(Id travelId:NSNumber, completion:@escaping (InfoTravelEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/init/\(travelId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // URL response
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from getReservations service")
                    completion(nil)
                    return
            }
            if (json?.count)! < 3{
                completion(nil)
            }else{
                let travelEntity = InfoTravelEntity.init(travelData: json!)
                completion(travelEntity)
            }
            
        }
    }
    
    func getCurrentTravelByIdDriver(_ driverId: NSNumber, completion:@escaping (InfoTravelEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/getCurrentTravelByIdDriver/\(driverId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from getReservations service")
                    completion(nil)
                    return
            }
            if (json?.count)! < 3{
                completion(nil)
            }else{
                let travelEntity = InfoTravelEntity.init(travelData: json!)
                completion(travelEntity)
            }
        }
    }
    
    func getReservations(_ driverId: NSNumber, completion:@escaping ([InfoTravelEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/rservations/\(driverId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            //print(response.request as Any)  // original URL request
            //print(response.response as Any) // URL response
            //print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            var travels = [InfoTravelEntity]()
            if dataJson != nil{
                for entitieJson in dataJson!{
                    let entity = InfoTravelEntity.init(travelData: entitieJson as! [String : Any])
                    travels.append(entity)
                }
                completion(travels)
            }else{
                completion(nil)
            }
            
        }
    }
    
    func readReservation(Id travelId:NSNumber, driverId: NSNumber, completion:@escaping ([InfoTravelEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/readrservations/\(travelId)/\(driverId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.request as Any)  // original URL request
            print(response.response as Any) // URL response
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            var travels = [InfoTravelEntity]()
            if dataJson != nil{
                for entitieJson in dataJson!{
                    let entity = InfoTravelEntity.init(travelData: entitieJson as! [String : Any])
                    travels.append(entity)
                }
                completion(travels)
            }else{
                completion(nil)
            }
            
        }
    }

    func cacelReservation(Id travelId:NSNumber, driverId: NSNumber, completion:@escaping ([InfoTravelEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/cacelReservation/\(travelId)/\(driverId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            var travels = [InfoTravelEntity]()
            if dataJson != nil{
                for entitieJson in dataJson!{
                    let entity = InfoTravelEntity.init(travelData: entitieJson as! [String : Any])
                    travels.append(entity)
                }
                completion(travels)
            }else{
                completion(nil)
            }
            
            
            
        }
    }
    
    func cancelByClient(Id travelId:String, idReasonCancelKf: String, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/cancelByClient/\(travelId)/\(idReasonCancelKf)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let jsonValue = response.result.value as? NSNumber else{
                print("Nil data received from loginUser service")
                completion(false)
                return
            }
            
            completion(jsonValue.boolValue)
        }
    }
    
    func obtIdMotivo(completion:@escaping ([ReasonEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("travel/reason")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            var reasonResponse = [ReasonEntity]()
            for entitieJson in dataJson!{
                let entity = ReasonEntity.init(reasonData: entitieJson as! [String : Any])
                reasonResponse.append(entity)
            }
            
            completion(reasonResponse)
        }
    }

}

// MARK: Driver
extension Http {
    
    func getAllTravel(_ driverId: String, completion:@escaping ([InfoTravelEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("driver/getAllTravel/\(driverId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            
            var travelResponse = [InfoTravelEntity]()
           // if let travelsJson = dataJson["reason"] as? [[String: Any]] {
            if json != nil{
                for travelJson in json!{
                    let travel = InfoTravelEntity.init(travelData: travelJson)
                    travelResponse.append(travel)
                }
            }
            
            completion(travelResponse)
        }
    }
    
    func getAllTravelClient(){
        
        if !isConnectedToInternet(){
            showInternetError()
            return
        }
    }
    
    func inactive(Id driverId:Int, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("driver/inactive/\(driverId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let jsonValue = response.result.value as? NSNumber else{
                print("Nil data received from loginUser service")
                completion(false)
                return
            }
            
            completion(jsonValue.boolValue)
        }
    }
    
    func active(Id driverId:Int, completion:@escaping (Bool) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("driver/active/\(driverId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            guard let jsonValue = response.result.value as? NSNumber else{
                print("Nil data received from loginUser service")
                completion(false)
                return
            }
            completion(jsonValue.boolValue)
        }
    }
    
    func listLiquidationDriver(_ driverId: String, completion:@escaping (listLiquidationDriverEntity?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("invoice/listLiquidationDriver/\(driverId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from listLiquidationDriver service")
                    completion(nil)
                    return
            }
            
            let listLiquidationDriver = listLiquidationDriverEntity.init(jsonData: json!)
            completion(listLiquidationDriver)
        }
    }
    
    
    
    func updateLiteMobil(){
        if !isConnectedToInternet(){
            showInternetError()
            return
        }
        
    }
    
    func filterForm(){
        if !isConnectedToInternet(){
            showInternetError()
            return
        }
        
    }
    
    func brand(_ completion:@escaping ([BrandEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("Brand")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
           
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            var brandResponse = [BrandEntity]()
            for entitieJson in dataJson!{
                let entity = BrandEntity.init(jsonData: entitieJson as! [String : Any])
                brandResponse.append(entity)
            }
            
            completion(brandResponse)
        }
    }
    
    func fleetType(_ completion:@escaping ([FleetTypeEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("fleetType")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            var fleetType = [FleetTypeEntity]()
            if dataJson != nil{
                
                for entitieJson in dataJson!{
                    let entity = FleetTypeEntity.init(jsonData: entitieJson as! [String : Any])
                    fleetType.append(entity)
                }
                
                completion(fleetType)
            }else{
                completion(nil)
            }
        }
    }
    
    func byidBrand(_ brandId: String, completion:@escaping ([ModelByBrand]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("model/byidBrand/\(brandId)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            guard let dataJson = json?["listModel"] as? [[String: Any]] else {
                print("Malformed data received from loginUser response service")
                completion(nil)
                return
            }
            
            var brandResponse = [ModelByBrand]()
            for entitieJson in dataJson{
                let entity = ModelByBrand.init(jsonData: entitieJson)
                brandResponse.append(entity)
            }
            
            completion(brandResponse)
        }
    }
    
    func filterFormfleetType(){
        if !isConnectedToInternet(){
            showInternetError()
            return
        }
        
    }
    
    func getModelDetail(){
        if !isConnectedToInternet(){
            showInternetError()
            return
        }
        
    }
    
    func addPluDriver(_ user:UserCreateEntity, fleet: FleetTypeEntity, completion:@escaping (NSNumber?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("driver/plusLite")
        let jsonUser = ["driver":user.toDriverJSON(), "fleet":fleet.toJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.response as Any)
            print(response.result.value as Any)   // result of response serialization
            
            guard let jsonValue = response.result.value as? NSNumber else{
                print("Nil data received from addPluDriver service")
                completion(nil)
                return
            }
            
            completion(jsonValue)
        }
        
    }
    
    func addClient(_ user:UserCreateEntity, completion:@escaping (Bool?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("client")
        let jsonUser = ["client":user.toClientJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let jsonValue = response.result.value as? NSNumber else{
                if response.result.value == nil{
                    completion(false)
                }else{
                    print("Nil data received from addClient service")
                    completion(true)
                }
                return
            }
            
            completion(jsonValue.boolValue)
        }
    }
    
    func validatorDomaint(_ mail:String, completion:@escaping ([EnterpriceEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("company/validatorDomaint/\(mail)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [NSDictionary] else {
                    print("Nil data received from loginUser service")
                    completion(nil)
                    return
            }
            
            if dataJson != nil{
                var enterpices = [EnterpriceEntity]()
                for entitieJson in dataJson!{
                    let entity = EnterpriceEntity.init(jsonData: entitieJson as! [String : Any])
                    enterpices.append(entity)
                }
                
                completion(enterpices)
            }else{
                completion(nil)
            }
        }
        
    }
    
    func getAcountByidCompany(_ idEnterprice:String, completion:@escaping ([CompanyAcountEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("company/getAcountByidCompany/\(idEnterprice)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    print("Nil data received from getAcountByidCompany service")
                    completion(nil)
                    return
            }
            
            var companyAcounts = [CompanyAcountEntity]()
            for entitieJson in dataJson!{
                let entity = CompanyAcountEntity.init(jsonData: entitieJson)
                companyAcounts.append(entity)
            }
            
            completion(companyAcounts)
        }
    }
    
    
    func costCenterByidAcount(_ idCompany:String, completion:@escaping ([CenterAcountEntity]?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("company/costCenterByidAcount/\(idCompany)")
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let dataJson = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    print("Nil data received from costCenterByidAcount service")
                    completion(nil)
                    return
            }
            
            var centers = [CenterAcountEntity]()
            for entitieJson in dataJson!{
                let entity = CenterAcountEntity.init(jsonData: entitieJson)
                centers.append(entity)
            }
            
            completion(centers)
        }
    }
}

extension Http{
    func addPlusDriverIDE(_ user:UserCreateEntity, fleet: FleetIDEEntity, completion:@escaping (NSNumber?) -> Void){
        if !isConnectedToInternet(){
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().urlDeveloper.appending("driver/plusLite")
        let jsonUser = ["driver":user.toDriverIDEJSON(), "fleet":fleet.toJSON()] as [String : Any]
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            print(response.result.value as Any)   // result of response serialization
            print(response.request as Any)  // original URL request
            print(response.response as Any) // URL response
            guard let jsonValue = response.result.value as? NSNumber else{
                print("Nil data received from addPluDriver service")
                completion(false)
                return
            }
            
            completion(jsonValue)
        }
        
    }
}

extension Http{
    func uploadImag(_ img:UIImage, name: String, completion:@escaping (Bool?) -> Void){
        
        if !isConnectedToInternet() || name == "0"{
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().masterIp.appending("/developer/Frond/safeimgDriver.php")
        
        let imgData = UIImageJPEGRepresentation(img, 0.2)!
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let base64String = imgData.base64EncodedString()
        let jsonUser = ["image":base64String, "filename":name, "mimeType":"image/jpeg"] as [String : Any]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: URLEncoding.default, headers: headers).responseString { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let _ = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    print("Nil data received from uploadImag service")
                    completion(true)
                    return
            }
            completion(true)
        }
    }
    
    func uploadSignature(_ img:UIImage, name: String, completion:@escaping (Bool?) -> Void){
        
        if !isConnectedToInternet() || name == "0"{
            showInternetError()
            completion(false)
            return
        }
        let url = GlobalMembers().masterIp.appending("/developer/Frond/safeimg.php")
        
        let imgData = UIImageJPEGRepresentation(img, 0.2)!
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let base64String = imgData.base64EncodedString()
        let jsonUser = ["image":base64String, "filename":name, "mimeType":"image/jpeg"] as [String : Any]
        Alamofire.request(url, method: .post, parameters: jsonUser, encoding: URLEncoding.default, headers: headers).responseString { response in
            print(response.result.value as Any)   // result of response serialization
            
            guard let data = response.data,
                let _ = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                    print("Nil data received from uploadSignature service")
                    completion(true)
                    return
            }
            completion(true)
        }
    }
    
    func dowloadImag(_ name: String, completion:@escaping (UIImage?) -> Void){
        
        if !isConnectedToInternet() || name == "0"{
            showInternetError()
            completion(nil)
            return
        }
        let url = GlobalMembers().masterIp.appending("/developer/Frond/img_users/\(name).JPEG")
        
        
        // Use Alamofire to download the image
        Alamofire.request(url).responseData { (response) in
            if response.error == nil {
                print(response.result)
                if let data = response.data {
                    let image = UIImage(data: data)
                    completion(image)
                }else{
                    completion(nil)
                }
            }else{
                completion(nil)
            }
            
        }
    }
}

extension Http{
    func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    func showInternetError(){
        let alertController = UIAlertController(title: "Erro de conexão", message: "Não foi possível conectar-se ao serviço, verifique sua conexão com a internet", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Aceitar", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        
        let window = UIWindow.init(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController.init()
        window.windowLevel = UIWindowLevelAlert+1
        window.makeKeyAndVisible()
        window.rootViewController?.present(alertController, animated: true, completion: nil)
        
        
    }
}



//
//  SingletonsObject.swift
//  AsRemis
//
//  Created by Luis F. Bustos Ramirez on 17/10/17.
//  Copyright © 2017 Apreciasoft. All rights reserved.
//

import UIKit
import CoreData

final class SingletonsObject: NSObject {
    static let sharedInstance = SingletonsObject()
    var userSelected: UserFullEntity?
    var appCurrentVersion: String = "0"
    var currentTrip: InfoTravelEntity?
    
    private override init() {super.init()}
    
    func saveUserSelectedWith(mail:String, pass:String){
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entityName = "UserEntityManaged"
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                managedContext.delete(object)
            }
        }
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        person.setValue(mail, forKeyPath: "mail")
        person.setValue(pass, forKeyPath: "password")
        person.setValue("", forKeyPath: "username")
        person.setValue(0, forKeyPath: "isDriver")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
   
}


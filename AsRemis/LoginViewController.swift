//
//  LoginViewController.swift
//  AsRemis
//
//  Created by Luis F. Bustos Ramirez on 27/09/17.
//  Copyright © 2017 Apreciasoft. All rights reserved.
//

import UIKit
import CoreData
import NVActivityIndicatorView

class LoginViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var asRemisImg: UIImageView!
    @IBOutlet weak var mailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var buildVersionLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Next!"
        
        self.navigationController?.navigationBar.barTintColor = UIColor.GrayAsRemis
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.hideKeyboardWhenTappedAround()
        loginBtn.backgroundColor = UIColor.GrayAsRemis
        buildVersionLbl.text = "Versión: \(SingletonsObject.sharedInstance.appCurrentVersion)"
        getCurrentUser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: Any) {
        let user = UserEntity.init(userName: mailTxtField.text!, userPass: passwordTxtField.text!, idTypeAuth: 2)
        let http = Http.init()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        http.checkVersion(SingletonsObject.sharedInstance.appCurrentVersion as String, completion: { (isValidVersion) -> Void in
            self.stopAnimating()
            if isValidVersion{
                http.loginUser(user, completion: { (userJson) -> Void in
                    if userJson != nil && userJson?.user?.emailUser != ""{
                        self.handleResponse(userJson!)
                    }else{
                        let alertController = UIAlertController(title: "Usuario no encontrado", message: "Usuario o contraseña son incorrectas,favor de intentar mas tarde", preferredStyle: UIAlertControllerStyle.alert)
                        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                            (result : UIAlertAction) -> Void in
                            print("OK")
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            }else{
                let alertController = UIAlertController(title: "Nueva actualización disponible", message: "Actualice su aplicación para continuar usandola", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
        
    }
    
    func handleResponse(_ user: UserFullEntity){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        if(user.driverInactive == 3){
            let alertController = UIAlertController(title: "Información", message: "Usuário / Off", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        SingletonsObject.sharedInstance.userSelected = user
        let http = Http.init()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        
        http.dowloadImag("\(SingletonsObject.sharedInstance.userSelected?.user?.idUser ?? 0)", completion: { (image) -> Void in
            self.stopAnimating()
            if image != nil{
                user.user?.imageProfile = image
                SingletonsObject.sharedInstance.userSelected?.user?.imageProfile = image
            }
        })
        
        let socket = SocketAsRemis()
        socket.createSocketConnectionWith(user: (user.user?.idUser)!)
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entityName = "UserEntityManaged"
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                managedContext.delete(object)
            }
        }
        
        var driverId = NSNumber.init(value: 0)
        if user.user?.idDriver != nil{
            driverId = (user.user?.idDriver)!
        }
        var isDriver = 0
        if driverId.intValue > 0{
            isDriver = 1
        }
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        person.setValue(user.user?.emailUser, forKeyPath: "mail")
        person.setValue(passwordTxtField.text, forKeyPath: "password")
        person.setValue(user.user?.firstNameUser, forKeyPath: "username")
        person.setValue(isDriver, forKeyPath: "isDriver")
        
        do {
            try managedContext.save()
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainMenuNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = viewController;
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func getCurrentUser(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEntityManaged")
        
        do {
            guard let currentUser = (try managedContext.fetch(fetchRequest).first) as? UserEntityManaged else {
                return
            }
            mailTxtField.text = currentUser.mail
            passwordTxtField.text = currentUser.password
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

}

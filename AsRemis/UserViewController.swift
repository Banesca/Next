//
//  UserViewController.swift
//  AsRemis
//
//  Created by Luis F. Bustos Ramirez on 29/09/17.
//  Copyright © 2017 Apreciasoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class UserViewController: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userNameTxtField: UITextField!
    @IBOutlet weak var lastNameLbl: UILabel!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var dniLbl: UILabel!
    @IBOutlet weak var dniTxtField: UITextField!
    @IBOutlet weak var mailLbl: UILabel!
    @IBOutlet weak var mailTxtField: UITextField!
    @IBOutlet weak var numTelLbl: UILabel!
    @IBOutlet weak var numTelTxtField: UITextField!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Bienvenido!"
        imagePicker.delegate = self
        
        
        let user = SingletonsObject.sharedInstance.userSelected
        userNameTxtField.text = user?.user?.firstNameUser
        lastNameTxtField.text = user?.user?.lastNameUser
        
        imageView.image = SingletonsObject.sharedInstance.userSelected?.user?.imageProfile ?? UIImage(named: "user.png")
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.clipsToBounds = true
        
        if user?.driver != nil{
            numTelTxtField.text = user!.driver?.phoneNumber
            mailTxtField.text = user!.driver?.email
            dniTxtField.text = user?.driver?.dni
        }
        else{
            numTelTxtField.text = user!.client?.phoneNumber
            mailTxtField.text = user!.client?.email
            dniTxtField.text = user?.client?.dni
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        imageView.addGestureRecognizer(tap)
        
        
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchPhoto(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camara", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.shootPhoto()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Galeria", style: UIAlertActionStyle.default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoFromLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func searchPhotoAction(_ sender: Any) {
        searchPhoto()
    }
    
    @IBAction func photoFromLibrary() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.modalPresentationStyle = .popover
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shootPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker,animated: true,completion: nil)
        } else {
            noCamera()
        }
    }

    func noCamera(){
        let alertVC = UIAlertController(
            title: "Sin camara",
            message: "Lo sentimos, este dispositivo no tiene una cámara",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "Aceptar",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    @IBAction func updateUser(_ sender: Any) {
        let http = Http()
        var statusDriver = NSNumber.init(value: 0)
        let user = SingletonsObject.sharedInstance.userSelected
        if user?.driver != nil{
            statusDriver = (user?.driver?.idStatusDriverTravelKf)!
        }
        let profile = UserProfileEntity.init(withIdProfile: (user?.user?.idProfileUser?.stringValue)!, firstName: userNameTxtField.text!, lastName: lastNameTxtField.text!, dni: dniTxtField.text!, phone: numTelTxtField.text!, email: mailTxtField.text!, idUser: (user!.user?.idUser)!, idStatusDriver: statusDriver)
        http.updateClientLiteMobil(profile, completion: { (userUpdated) -> Void in
            if userUpdated != nil{
                let alertController = UIAlertController(title: "Datos actualizados", message: "Sus datos se actualizaron", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }else{
                let alertController = UIAlertController(title: "Error al actualizar", message: "Sus datos no se pueden actualizar, inténtelo más tarde", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        })
    }
}
extension  UserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let http = Http.init()
            startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
            http.uploadImag(pickedImage, name: "\(SingletonsObject.sharedInstance.userSelected?.user?.idUser ?? 0)", completion: { (response) -> Void in
                                self.stopAnimating()
                                if response!{
                                    self.imageView.image = pickedImage
                                    SingletonsObject.sharedInstance.userSelected?.user?.imageProfile = pickedImage
                                }else{
                                    let alertController = UIAlertController(title: "Información", message: "No se pudo actualizar la imagen del perfil, inténtelo más tarde", preferredStyle: UIAlertControllerStyle.alert)
                                    let okAction = UIAlertAction(title: "Aceitar", style: UIAlertActionStyle.default) {
                                        (result : UIAlertAction) -> Void in
                                        print("OK")
                                    }
                                    alertController.addAction(okAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
            })
            
        }
        dismiss(animated: true, completion: nil)
    }
  
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension UserViewController: UIGestureRecognizerDelegate{
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        searchPhoto()
    }
}

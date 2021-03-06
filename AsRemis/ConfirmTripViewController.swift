//
//  ConfirmTripViewController.swift
//  IDE
//
//  Created by Luis Fernando Bustos Ramírez on 1/5/18.
//  Copyright © 2018 Apreciasoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import EPSignature

class ConfirmTripViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var confirmMessageLbl: UILabel!
    @IBOutlet weak var mountToPayLbl: UILabel!
    @IBOutlet weak var distanceTxtField: UITextField!
    @IBOutlet weak var timeTxtField: UITextField!
    @IBOutlet weak var peajeTxtField: UITextField!
    @IBOutlet weak var parkingTxtField: UITextField!
    @IBOutlet weak var payWithCreditCardView: UIView!
    @IBOutlet weak var payWithCashView: UIView!
    @IBOutlet weak var signView: UIView!
    var idPaymentFormKf = NSNumber(value: 1)
    var signatureImg = UIImage()
   
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let tapCredit = UITapGestureRecognizer(target: self, action: #selector(self.handleTapCredit(sender:)))
        tapCredit.delegate = self
        payWithCreditCardView.addGestureRecognizer(tapCredit)
        
        let tapCash = UITapGestureRecognizer(target: self, action: #selector(self.handleTapCash(sender:)))
        tapCash.delegate = self
        payWithCashView.addGestureRecognizer(tapCash)
        
        let tapSign = UITapGestureRecognizer(target: self, action: #selector(self.handleTapSign(sender:)))
        tapSign.delegate = self
        signView.addGestureRecognizer(tapSign)
        
        prepareView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareView(){
        mountToPayLbl.text = String(format: "$%.2f", LocationTripObject.sharedInstance.totalCost)
        distanceTxtField.text = String(format: "%.2fKm - $%.2f",LocationTripObject.sharedInstance.totalDistance, LocationTripObject.sharedInstance.totalCost)
        timeTxtField.text = String(format: "%.2fHrs - $%.2f",LocationTripObject.sharedInstance.waitTime/60, LocationTripObject.sharedInstance.timeCost)
    }
}

extension ConfirmTripViewController: UIGestureRecognizerDelegate{
    @objc func handleTapCredit(sender: UITapGestureRecognizer? = nil) {
         idPaymentFormKf = NSNumber(value: 0)
//        self.dismiss(animated: true, completion: nil)
//        SingletonsObject.sharedInstance.currentTrip = nil
//        NotificationCenter.default.post(name: Notification.Name(updateViewByTrip),object: nil)
    }
    
    @objc func handleTapCash(sender: UITapGestureRecognizer? = nil) {
         idPaymentFormKf = NSNumber(value: 1)
//        self.dismiss(animated: true, completion: nil)
//        SingletonsObject.sharedInstance.currentTrip = nil
//        NotificationCenter.default.post(name: Notification.Name(updateViewByTrip),object: nil)
    }
    
    @objc func handleTapSign(sender: UITapGestureRecognizer? = nil) {
        let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: false, showsSaveSignatureOption: false)
        signatureVC.subtitleText = "Ingrese su firma y pulse Done"
        signatureVC.title = "Firmar Voucher"
        let nav = UINavigationController(rootViewController: signatureVC)
        self.present(nav, animated: true, completion: nil)
    }
}

extension ConfirmTripViewController: EPSignatureDelegate{
    func epSignature(_: EPSignature.EPSignatureViewController, didCancel error: NSError){
        let alertController = UIAlertController(title: "Se necesita la firma para completar el viaje", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func epSignature(_: EPSignature.EPSignatureViewController, didSign signatureImage: UIImage, boundingRect: CGRect){
        signatureImg = signatureImage
        let http = Http.init()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Finalizando viaje", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        http.uploadImag(signatureImg, name: "\(SingletonsObject.sharedInstance.currentTrip?.idTravel ?? 0)", completion: { (response) -> Void in
            let travelLocation = TravelLocationEntity(
                idTravelKf: (SingletonsObject.sharedInstance.currentTrip?.idTravel)!,
                totalAmount: NSNumber(value:LocationTripObject.sharedInstance.totalCost),
                distanceGps: NSNumber(value:(LocationTripObject.sharedInstance.distancesInReturn + LocationTripObject.sharedInstance.distanceNormal)),
                distanceGpsLabel: "\((LocationTripObject.sharedInstance.distancesInReturn + LocationTripObject.sharedInstance.distanceNormal))",
                location: "",
                longLocation: "\(LocationTripObject.sharedInstance.userPosition?.coordinate.longitude ?? 0.0)",
                latLocation: "\(LocationTripObject.sharedInstance.userPosition?.coordinate.latitude ?? 0.0)",
                amounttoll: 0,
                amountParking: 0,
                amountTiemeSlepp: 0,
                timeSleppGps: "0",
                idPaymentFormKf: self.idPaymentFormKf) //TODO; Revisar valor
            let finisEnable = Int(SingletonsObject.sharedInstance.userSelected?.params?[19].value ?? "0")!
            if finisEnable == 1{
                http.finishMobil(travelLocation,completion: {(travels) -> Void in
                    self.stopAnimating()
                    NotificationCenter.default.post(name: Notification.Name(updateViewByTrip),object: nil)
                })
                
            }else{
                //TODO: Revisar prefinish
                //http.preFinishMobil(travelLocation,completion: {(travels) -> Void in
                http.finishMobil(travelLocation,completion: {(travels) -> Void in
                    self.stopAnimating()
                    NotificationCenter.default.post(name: Notification.Name(updateViewByTrip),object: nil)
                })
                
            }
            
            
            self.stopAnimating()
            SingletonsObject.sharedInstance.currentTrip = nil
            self.dismiss(animated: true, completion: nil)
        })
    }
}


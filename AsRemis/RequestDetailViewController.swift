//
//  RequestDetailViewController.swift
//  IDE
//
//  Created by Luis Fernando Bustos Ramírez on 1/10/18.
//  Copyright © 2018 Apreciasoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RequestDetailViewController: UIViewController, NVActivityIndicatorViewable {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var clientNameLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var passagersLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var destinationLbl: UILabel!
    @IBOutlet weak var originLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var revokeBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var searchClientBtn: UIButton!
    var request: InfoTravelEntity?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Detalles del viaje"
        titleLbl.text = request?.codTravel
        clientNameLbl.text = request?.client
        distanceLbl.text = request?.distanceLabel
        costLbl.text = request?.amountCalculate
        passagersLbl.text = request?.client
        dateLbl.text = request?.dateTravel
        destinationLbl.text = request?.nameDestination
        originLbl.text = request?.nameOrigin
        phoneLbl.text = request?.phoneClient ?? "No se cargo información"
        detailsLbl.text = request?.obsertavtionFlight ?? "No se cargo información"
        if request?.nameStatusTravel == "Espera de Aceptacion"{
            searchClientBtn.isHidden = true
        }else{
            confirmBtn.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func revokeTrip(_ sender: Any) {
        let http = Http()
        let idDriver = (SingletonsObject.sharedInstance.userSelected?.user?.idDriver)!
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        http.cacelReservation(Id: (SingletonsObject.sharedInstance.currentTrip?.idTravel)!, driverId: idDriver, completion: {(travels) -> Void in
            self.stopAnimating()
            SingletonsObject.sharedInstance.currentTrip = nil
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func confirmTrip(_ sender: Any) {
        let http = Http()
        if ((SingletonsObject.sharedInstance.userSelected?.user?.idDriver?.stringValue) != nil){
            let idValue = (SingletonsObject.sharedInstance.userSelected?.user?.idDriver)!
            startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
            http.readReservation(Id: (request?.idTravel)!, driverId: idValue, completion: {(travels) -> Void in
                self.stopAnimating()
                //SingletonsObject.sharedInstance.currentTrip = travel
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    
    @IBAction func searchClient(_ sender: Any) {
        let http = Http()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        http.accept(Id: (request?.idTravel)!, completion: {(travel) -> Void in
            self.stopAnimating()
            SingletonsObject.sharedInstance.currentTrip = travel
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        })
    }
    

}

//
//  InfoTravelViewController.swift
//  IDE
//
//  Created by Luis Fernando Bustos Ramírez on 1/5/18.
//  Copyright © 2018 Apreciasoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol InfoTravelViewDelegate {
    func acceptTrip()
    func tripInCourse()
    func deniedTrip()
}

class InfoTravelViewController: UIViewController, NVActivityIndicatorViewable {
    @IBOutlet weak var numInfoTravelLbl: UILabel!
    @IBOutlet weak var namePasagersListLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var dirOrigenLbl: UILabel!
    @IBOutlet weak var dirDestinationLbl: UILabel!
    @IBOutlet weak var costLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var multiStartedListLbl: UILabel!
    @IBOutlet weak var multiDestinationsListLbl: UILabel!
    @IBOutlet weak var observationsLbl: UILabel!
    @IBOutlet weak var acceptView: UIView!
    @IBOutlet weak var cancelView: UIView!
    var delegate: InfoTravelViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapAccept = UITapGestureRecognizer(target: self, action: #selector(self.handleTapAccept(sender:)))
        tapAccept.delegate = self
        acceptView.addGestureRecognizer(tapAccept)
        
        let tapCancel = UITapGestureRecognizer(target: self, action: #selector(self.handleTapCancel(sender:)))
        tapCancel.delegate = self
        cancelView.addGestureRecognizer(tapCancel)
        
        self.checkCurrentTrip()
    }
    
    func checkCurrentTrip(){
        let http = Http.init()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        let idDriver = (SingletonsObject.sharedInstance.userSelected?.user?.idDriver)!
        http.getCurrentTravelByIdDriver(idDriver, completion: { (trip) -> Void in
            self.stopAnimating()
            if trip != nil{
                SingletonsObject.sharedInstance.currentTrip = trip
                self.numInfoTravelLbl.text = trip?.codTravel
                var passagers = ""
                passagers.append(trip?.pasajero ?? "")
                self.namePasagersListLbl.text = passagers
                self.dateLbl.text = trip?.dateTravel
                if (trip?.origin?.name?.count)! > 0{
                    self.dirOrigenLbl.text = trip?.origin?.name
                }else{
                    self.dirOrigenLbl.text = " "
                }
                if (trip?.destination?.name?.count)! > 0{
                    self.dirDestinationLbl.text = trip?.destination?.name
                }else{
                    self.dirDestinationLbl.text = " "
                }
                self.costLbl.text = trip?.amountCalculate
                self.distanceLbl.text = trip?.distanceLabel
                var multiOrigin = ""
                multiOrigin.append("1)")
                multiOrigin.append(trip?.OriginMultiple1?.name ?? "No Pose")
                multiOrigin.append(" - 2)")
                multiOrigin.append(trip?.OriginMultiple2?.name ?? "No Pose")
                multiOrigin.append(" - 3)")
                multiOrigin.append(trip?.OriginMultiple3?.name ?? "No Pose")
                multiOrigin.append(" - 4)")
                multiOrigin.append(trip?.OriginMultiple4?.name ?? "No Pose")
                self.multiStartedListLbl.text = multiOrigin
                self.multiDestinationsListLbl.text = trip?.MultiDestination
                self.observationsLbl.text = trip?.obsertavtionFlight
                self.checkTripStatus()
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func checkTripStatus(){
        if SingletonsObject.sharedInstance.currentTrip?.nameStatusTravel == "Espera de Aceptacion"{
            return
        }
        if SingletonsObject.sharedInstance.currentTrip?.nameStatusTravel == "En Curso"{
            self.dismiss(animated: true, completion: nil)
            self.delegate?.tripInCourse()
        }
        if SingletonsObject.sharedInstance.currentTrip?.nameStatusTravel == "Busqueda de Cliente"{
            self.dismiss(animated: true, completion: nil)
            self.delegate?.acceptTrip()
        }
        if SingletonsObject.sharedInstance.currentTrip?.nameStatusTravel == "Cancelado"{
            let http = Http.init()
            startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
            http.accept(Id: (SingletonsObject.sharedInstance.currentTrip?.idTravel)!, completion: {(accept) -> Void in
                self.stopAnimating()
                self.dismiss(animated: true, completion: nil)
                self.delegate?.acceptTrip()
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension InfoTravelViewController: UIGestureRecognizerDelegate{
    @objc func handleTapAccept(sender: UITapGestureRecognizer? = nil) {
        let http = Http.init()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        http.accept(Id: (SingletonsObject.sharedInstance.currentTrip?.idTravel)!, completion: {(travel) -> Void in
            SingletonsObject.sharedInstance.currentTrip = travel
            self.stopAnimating()
            self.dismiss(animated: true, completion: nil)
            self.delegate?.acceptTrip()
        })
    }
    
    @objc func handleTapCancel(sender: UITapGestureRecognizer? = nil) {
        let http = Http.init()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        let idDriver = (SingletonsObject.sharedInstance.userSelected?.user?.idDriver)!
        http.cacelReservation(Id: (SingletonsObject.sharedInstance.currentTrip?.idTravel)!, driverId: idDriver, completion: {(travels) -> Void in
            SingletonsObject.sharedInstance.currentTrip = nil
            self.stopAnimating()
            self.dismiss(animated: true, completion: nil)
            self.delegate?.deniedTrip()
        })
    }
}



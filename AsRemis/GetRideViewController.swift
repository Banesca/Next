//
//  GetRideViewController.swift
//  AsRemis
//
//  Created by Luis Fernando Bustos Ramírez on 9/24/17.
//  Copyright © 2017 Apreciasoft. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
import NVActivityIndicatorView

class GetRideViewController: BaseViewController, NVActivityIndicatorViewable{
    @IBOutlet weak var googleMapsView: GMSMapView!
    @IBOutlet weak var floatingBtn: UIButton!
    @IBOutlet weak var requestLbl: UILabel!
    @IBOutlet weak var floatingOption1Btn: UIButton!
    @IBOutlet weak var floatingOption2Btn: UIButton!
    @IBOutlet weak var scheduleLbl: UILabel!
    
    @IBOutlet weak var bottomFloatingOpt1Constraint: NSLayoutConstraint!
    @IBOutlet weak var bottomFloatingOpt2Constraint: NSLayoutConstraint!
    @IBOutlet weak var optionsLbl: UILabel!
    
    @IBOutlet weak var servicesByClient: UIView!
    @IBOutlet weak var servicesByDriver: UIView!
    @IBOutlet weak var requestServicesView: UIView!
    @IBOutlet weak var scheduleServicesView: UIView!
    
    @IBOutlet weak var locationBtn: UIButton!
    @IBOutlet weak var heightServicesDriverConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightServicesClientConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var heightServicesClientDetailConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightServicesDriverDetailConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomServicesClientDetailConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var heightRequestServicesConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightScheduleServicesConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var changeDriverStatusBtn: UIButton!
    
    @IBOutlet weak var driverOptionsStackView: UIStackView!
    @IBOutlet weak var cancelTripView: UIView!
    @IBOutlet weak var startTripView: UIView!
    @IBOutlet weak var waitTripView: UIView!
    @IBOutlet weak var endTripView: UIView!
    @IBOutlet weak var turnTripView: UIView!
    
    var currentUser = UserEntityManaged()
    var showUserLocation = true
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Bienvenido!"
        self.addSlideMenuButton()
        
        floatingBtn.layer.cornerRadius = floatingBtn.bounds.size.height/2
        floatingBtn.clipsToBounds = true
        optionsLbl.isHidden = true
        floatingOption1Btn.layer.cornerRadius = floatingOption1Btn.bounds.size.height/2
        floatingOption1Btn.clipsToBounds = true
        floatingOption1Btn.isHidden = true
        requestLbl.isHidden = true
        floatingOption2Btn.layer.cornerRadius = floatingOption2Btn.bounds.size.height/2
        floatingOption2Btn.clipsToBounds = true
        scheduleLbl.isHidden = true
        floatingOption2Btn.isHidden = true
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        googleMapsView.isMyLocationEnabled = true
        
        getCurrentUser()
        
        if currentUser.isDriver{
            heightServicesClientConstraint.constant = 0
            floatingBtn.isHidden = true
            floatingOption1Btn.isHidden = true
            floatingOption2Btn.isHidden = true
        }else{
            heightServicesDriverConstraint.constant = 0
            changeDriverStatusBtn.isHidden = true
        }
        bottomServicesClientDetailConstraint.constant = -60
        heightServicesClientDetailConstraint.constant = 0
        heightServicesDriverDetailConstraint.constant = 0
        heightRequestServicesConstraint.constant = 0
        heightScheduleServicesConstraint.constant = 0
        requestServicesView.isHidden = true
        scheduleServicesView.isHidden = true
        
        self.view.layoutIfNeeded()
        self.prepareTripTaps()
        showUserLocation = true
        
        NotificationCenter.default.addObserver( self, selector: #selector(self.showTripRequest),name: NSNotification.Name(showTripRequestNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver( self, selector: #selector(self.showTripRequest),name: NSNotification.Name(showTripRequestNotification), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        self.hideTripButtons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func locationAction(_ sender: Any) {
       locationManager.startUpdatingLocation()
        showUserLocation = true
    }
    
    @IBAction func floatingAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            if self.bottomFloatingOpt1Constraint.constant == 0{
                self.bottomFloatingOpt1Constraint.constant = -55
                self.bottomFloatingOpt2Constraint.constant = -110
                self.floatingOption1Btn.isHidden = false
                self.floatingOption2Btn.isHidden = false
                self.requestLbl.isHidden = false
                self.scheduleLbl.isHidden = false
                self.optionsLbl.isHidden = false
                self.floatingBtn.setTitle("x", for: UIControlState.normal)
            }else{
                self.bottomFloatingOpt1Constraint.constant = 0
                self.bottomFloatingOpt2Constraint.constant = 0
                self.requestLbl.isHidden = true
                self.scheduleLbl.isHidden = true
                self.optionsLbl.isHidden = true
                self.floatingBtn.setTitle("+", for: UIControlState.normal)
            }
            self.heightRequestServicesConstraint.constant = 0
            self.requestServicesView.isHidden = true
            self.heightScheduleServicesConstraint.constant = 0
            self.scheduleServicesView.isHidden = true
            self.view.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            if self.bottomFloatingOpt1Constraint.constant == 0{
                self.floatingOption1Btn.isHidden = true
                self.floatingOption2Btn.isHidden = true
                self.requestLbl.isHidden = true
                self.scheduleLbl.isHidden = true
                self.optionsLbl.isHidden = true
            }
        })
        
        if sender == floatingOption1Btn{
            heightRequestServicesConstraint.constant = 200
            requestServicesView.isHidden = false
        }
        if sender == floatingOption2Btn{
            heightScheduleServicesConstraint.constant = 220
            scheduleServicesView.isHidden = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueID = segue.identifier ?? ""
        
        getCurrentUser()
        switch segueID
        {
        case "servicesAsClient","servicesAsDriver":
            let destinationVC = segue.destination as! ServicesActiveViewController
            destinationVC.isDriver = currentUser.isDriver
            destinationVC.delegate = self
            break
            
        case "servicesDetailAsClient":
            let destinationVC = segue.destination as! ServicesActionsDetailViewController
            destinationVC.isDriver = false
            break
        case "servicesDetailAsDriver":
            let destinationVC = segue.destination as! ServicesActionsDetailViewController
            destinationVC.isDriver = currentUser.isDriver
            break
        case "makeAReservation":
            let destinationVC = segue.destination as! MakeReservationViewController
            destinationVC.delegate = self
            break
        case "requestAServices":
            let destinationVC = segue.destination as! RequestServicesViewController
            destinationVC.delegate = self
            break
        default:
            break
        }
    }
    
    func getCurrentUser(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "UserEntityManaged")
        
        do {
            currentUser = (try managedContext.fetch(fetchRequest).first)! as! UserEntityManaged
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    @IBAction func changeDriverStatusAction(_ sender: Any) {
        let http = Http()
        let driverId = SingletonsObject.sharedInstance.userSelected?.user?.idDriver?.intValue
        if SingletonsObject.sharedInstance.userSelected?.user?.idStatusUser == "0"{
            http.active(Id: driverId!, completion:{(response) -> Void in
                if response{
                    SingletonsObject.sharedInstance.userSelected?.user?.idStatusUser = "1"
                    self.changeDriverStatusBtn.imageView?.image = UIImage.init(named: "ic_pause_circle_filled_48pt")
                    let alertController = UIAlertController(title: "Cuenta activada", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        print("Aceitar")
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        else{
            http.inactive(Id: driverId!, completion:{(response) -> Void in
                if response{
                    SingletonsObject.sharedInstance.userSelected?.user?.idStatusUser = "0"
                    self.changeDriverStatusBtn.imageView?.image = UIImage.init(named: "ic_play_circle_filled_48pt")
                    let alertController = UIAlertController(title: "Cuenta inactivada", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Aceptar", style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        print("Aceitar")
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            })
        }
    }
    
    func hideTripButtons(){
        driverOptionsStackView.isHidden = true
        cancelTripView.isHidden = true
        startTripView.isHidden = true
        waitTripView.isHidden = true
        endTripView.isHidden = true
        turnTripView.isHidden = true
    }
    
    func showTripInCourseButton(){
        self.hideTripButtons()
        driverOptionsStackView.spacing = 20.0
        driverOptionsStackView.isHidden = false
        waitTripView.isHidden = false
        endTripView.isHidden = false
        turnTripView.isHidden = false
    }
    
    func prepareTripTaps(){
        let tapStart = UITapGestureRecognizer(target: self, action: #selector(self.handleTapStart(sender:)))
        tapStart.delegate = self
        startTripView.addGestureRecognizer(tapStart)
        
        let tapCancel = UITapGestureRecognizer(target: self, action: #selector(self.handleTapCancel(sender:)))
        tapCancel.delegate = self
        cancelTripView.addGestureRecognizer(tapCancel)
        
        let tapWait = UITapGestureRecognizer(target: self, action: #selector(self.handleTapWait(sender:)))
        tapWait.delegate = self
        waitTripView.addGestureRecognizer(tapWait)
        
        let tapEnd = UITapGestureRecognizer(target: self, action: #selector(self.handleTapEnd(sender:)))
        tapEnd.delegate = self
        endTripView.addGestureRecognizer(tapEnd)
        
        let tapTurn = UITapGestureRecognizer(target: self, action: #selector(self.handleTapTurn(sender:)))
        tapTurn.delegate = self
        turnTripView.addGestureRecognizer(tapTurn)
    }
}

extension GetRideViewController{
    @objc func showTripRequest(notification: NSNotification){
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "InfoTravelViewController") as! InfoTravelViewController
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.delegate = self
        self.present(viewController, animated: true, completion: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(showTripRequestNotification), object: nil)
    }
}

extension GetRideViewController: UIGestureRecognizerDelegate{
    @objc func handleTapStart(sender: UITapGestureRecognizer? = nil) {
        let http = Http.init()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        http.initTrip(Id: (SingletonsObject.sharedInstance.currentTrip?.idTravel)!, completion:{(currentTrip) -> Void in
            self.stopAnimating()
            self.dismiss(animated: true, completion: nil)
            SingletonsObject.sharedInstance.currentTrip = currentTrip
            NotificationCenter.default.post(name: Notification.Name(updateViewByTrip),object: nil)
            self.showTripInCourseButton()
            LocationTripObject.sharedInstance.startSendLocation()
        })
    }
    
    @objc func handleTapCancel(sender: UITapGestureRecognizer? = nil) {
        let http = Http.init()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        let idDriver = (SingletonsObject.sharedInstance.userSelected?.user?.idDriver)!
        http.cacelReservation(Id: (SingletonsObject.sharedInstance.currentTrip?.idTravel)! , driverId: idDriver, completion: {(travels) -> Void in
            self.stopAnimating()
            self.hideTripButtons()
            SingletonsObject.sharedInstance.currentTrip = nil
            NotificationCenter.default.post(name: Notification.Name(updateViewByTrip),object: nil)
            NotificationCenter.default.addObserver( self, selector: #selector(self.showTripRequest),name: NSNotification.Name(showTripRequestNotification), object: nil)
            
        })
    }
    
    @objc func handleTapWait(sender: UITapGestureRecognizer? = nil) {
        let http = Http.init()
        if LocationTripObject.sharedInstance.tripIsWait == 0{
            LocationTripObject.sharedInstance.tripIsWait = 1
        }else{
            LocationTripObject.sharedInstance.tripIsWait = 0
        }
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        http.isWait(Id: (SingletonsObject.sharedInstance.currentTrip?.idTravel)!, value: "\(LocationTripObject.sharedInstance.tripIsWait)", completion: {(currentTrip) -> Void in
            self.stopAnimating()
            if LocationTripObject.sharedInstance.tripIsWait == 0{
                self.waitTripView.backgroundColor = .gray
            }else{
                self.waitTripView.backgroundColor = .green
            }
        })
    }
    
    @objc func handleTapEnd(sender: UITapGestureRecognizer? = nil) {
        LocationTripObject.sharedInstance.checkCurrentDistance()
        LocationTripObject.sharedInstance.checkTotalCost()
        LocationTripObject.sharedInstance.stopSendLocation()
        self.hideTripButtons()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "ConfirmTripViewController")
        self.present(viewController, animated: true, completion: nil)
    }
    
    
    @objc func handleTapTurn(sender: UITapGestureRecognizer? = nil) {
        let http = Http.init()
        startAnimating(CGSize.init(width: 50, height: 50), message: "Espere un momento", messageFont: UIFont.boldSystemFont(ofSize: 12), type: .ballRotate, color: .white, padding: 0.0, displayTimeThreshold: 10, minimumDisplayTime: 2, backgroundColor: .GrayAlpha, textColor: .white)
        http.isRoundTrip(Id: (SingletonsObject.sharedInstance.currentTrip?.idTravel)!, completion:{(travels) -> Void in
            self.stopAnimating()
            self.turnTripView.isUserInteractionEnabled = false
            LocationTripObject.sharedInstance.isReturn = 1
        })
    }
}

extension GetRideViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        googleMapsView.clear()
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 15.0)
        
        let marker = GMSMarker()
        marker.position = camera.target
        
        var markerImage = UIImage(named: "kid")!.withRenderingMode(.automatic)
        if currentUser.isDriver{
             markerImage = UIImage(named: "taxi")!.withRenderingMode(.automatic)
        }
        let markerView = UIImageView(image: markerImage)
        
        marker.iconView = markerView
        marker.map = googleMapsView
        
        if(showUserLocation){
            googleMapsView.animate(to: camera)
            googleMapsView.camera = camera
            showUserLocation = false
        }
        LocationTripObject.sharedInstance.userPosition = location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            googleMapsView.isMyLocationEnabled = true
        }
    }
}

extension GetRideViewController : ServicesActiveDelegate{
    func showDetail() {
        self.floatingOption1Btn.isHidden = true
        self.floatingOption2Btn.isHidden = true
        self.bottomFloatingOpt1Constraint.constant = 0
        self.bottomFloatingOpt2Constraint.constant = 0
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            if self.currentUser.isDriver {
                if self.heightServicesDriverDetailConstraint.constant == 0 {
                    self.heightServicesDriverDetailConstraint.constant = 400
                    //self.floatingBtn.isHidden = true
                }else{
                    self.heightServicesDriverDetailConstraint.constant = 0
                    //self.floatingBtn.isHidden = false
                }
            }else{
                if self.heightServicesClientDetailConstraint.constant == 0 {
                    self.heightServicesClientDetailConstraint.constant = 400
                    self.bottomServicesClientDetailConstraint.constant = 0
                    self.floatingBtn.isHidden = true
                }else{
                    self.heightServicesClientDetailConstraint.constant = 0
                    self.bottomServicesClientDetailConstraint.constant = -60
                    self.floatingBtn.isHidden = false
                }
            }
            self.view.layoutIfNeeded()
        }, completion: { (finished) -> Void in
        })
    }
}

extension GetRideViewController : MakeReservationDelegate{
    func hideReservation() {
        self.heightScheduleServicesConstraint.constant = 0
        self.scheduleServicesView.isHidden = true
        self.view.layoutIfNeeded()
    }
}

extension GetRideViewController: RequestServicesDelegate{
    func hideRequest() {
        self.heightRequestServicesConstraint.constant = 0
        self.requestServicesView.isHidden = true
        self.view.layoutIfNeeded()
        
        let waitView = WaitForDriverViewController(nibName: "WaitForDriverViewController", bundle: nil)
        waitView.modalTransitionStyle = .crossDissolve
        waitView.modalPresentationStyle = .overCurrentContext
        
        self.present(waitView, animated: true, completion: nil)
    }
    
    func increaseHeightOfRequestView(_ increase: Bool){
        if increase{
            heightRequestServicesConstraint.constant = 350
        }else{
            heightRequestServicesConstraint.constant = 200
        }
    }
}

extension GetRideViewController: InfoTravelViewDelegate{
    func acceptTrip() {
        driverOptionsStackView.isHidden = false
        cancelTripView.isHidden = false
        startTripView.isHidden = false
        driverOptionsStackView.spacing = 130.0
        NotificationCenter.default.post(name: Notification.Name(updateViewByTrip),object: nil)
    }
    
    func deniedTrip() {
        NotificationCenter.default.addObserver( self, selector: #selector(self.showTripRequest),name: NSNotification.Name(showTripRequestNotification), object: nil)
    }
    
    func tripInCourse(){
        driverOptionsStackView.isHidden = false
        endTripView.isHidden = false
        turnTripView.isHidden = false
        waitTripView.isHidden = false
        driverOptionsStackView.spacing = 20.0
        LocationTripObject.sharedInstance.startSendLocation()
        NotificationCenter.default.post(name: Notification.Name(updateViewByTrip),object: nil)
    }
    
}

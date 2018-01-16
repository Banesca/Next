//
//  ServicesActiveViewController.swift
//  AsRemis
//
//  Created by Luis F. Bustos Ramirez on 02/10/17.
//  Copyright © 2017 Apreciasoft. All rights reserved.
//

import UIKit

protocol ServicesActiveDelegate {
    func showDetail()
}

class ServicesActiveViewController: UIViewController {
    
    var delegate : ServicesActiveDelegate?
    var isDriver = false
    
    @IBOutlet weak var servicesImg: UIImageView!
    @IBOutlet weak var servicesBtn: UIButton!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var servicesImgWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver( self, selector: #selector(self.updateView),name: NSNotification.Name(updateViewByTrip), object: nil)
        if isDriver{
            servicesImgWidthConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func getServices(_ sender: Any) {
        delegate?.showDetail()
    }
    
    @objc func updateView(notification: NSNotification){
        self.prepareView()
    }
    
    func prepareView(){
        if SingletonsObject.sharedInstance.currentTrip != nil{
            servicesBtn.setTitle(SingletonsObject.sharedInstance.currentTrip?.nameStatusTravel, for: .normal)
            distanceLbl.text = SingletonsObject.sharedInstance.currentTrip?.distanceLabel
            priceLbl.text = SingletonsObject.sharedInstance.currentTrip?.amountCalculate
        }else{
            priceLbl.text = "0$"
            distanceLbl.text = "0Km"
            servicesBtn.setTitle("SERVICIO ACTIVO", for: .normal)
        }
    }

}


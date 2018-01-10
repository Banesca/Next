//
//  RequestViewController.swift
//  AsRemis
//
//  Created by Luis Fernando Bustos Ramírez on 9/24/17.
//  Copyright © 2017 Luis Fernando Bustos Ramírez. All rights reserved.
//

import UIKit
import  NVActivityIndicatorView

class RequestViewController: BaseViewController, NVActivityIndicatorViewable{
    
    @IBOutlet weak var requestTV: UITableView!
    var requestList = [InfoTravelEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSlideMenuButton()
        navigationItem.title = "Bienvenido!"
        requestTV.delegate = self
        requestTV.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getRequestList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getRequestList(){
        let http = Http()
        if ((SingletonsObject.sharedInstance.userSelected?.user?.idDriver?.stringValue) != nil){
            let idValue = (SingletonsObject.sharedInstance.userSelected?.user?.idDriver)!
            http.getReservations(idValue, completion: {(travels) -> Void in
                self.requestList = [InfoTravelEntity]()
                if travels != nil{
                    for travel in travels!{
                        self.requestList.append(travel)
                    }
                    self.requestTV.reloadData()
                }
            })
        }
    }
}

extension RequestViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reservationCell", for: indexPath)
        let reservation = requestList[indexPath.row]
        let titleLbl = cell.viewWithTag(100) as! UILabel
        titleLbl.text = reservation.codTravel
        let statusBTN = cell.viewWithTag(101) as! UIButton
        if reservation.nameStatusTravel == "Espera de Aceptacion"{
            statusBTN.backgroundColor = .red
            statusBTN.setImage(UIImage.init(named: "ic_clear_white_48pt"), for: .normal)
        }else{
            statusBTN.backgroundColor = .green
            statusBTN.setImage(UIImage.init(named: "ic_check_white_48pt"), for: .normal)
        }
        let userNameLbl = cell.viewWithTag(102) as! UILabel
        userNameLbl.text = reservation.client
        let locationNameLbl = cell.viewWithTag(103) as! UILabel
        locationNameLbl.text = reservation.nameOrigin
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reservation = requestList[indexPath.row]
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "RequestDetailViewController") as! RequestDetailViewController
        viewController.request = reservation
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

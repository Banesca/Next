//
//  ServicesActionsDetailViewController.swift
//  AsRemis
//
//  Created by Luis F. Bustos Ramirez on 02/10/17.
//  Copyright © 2017 Apreciasoft. All rights reserved.
//

import UIKit

class ServicesActionsDetailViewController: UIViewController {
    
    @IBOutlet weak var servicesInformationTV: UITableView!
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var subImg: UIImageView!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var subImg2: UIImageView!
    @IBOutlet weak var subLbl2: UILabel!
    @IBOutlet weak var viewForDriverHeightConstraint: NSLayoutConstraint!
    
    var isDriver = false
    var statusInfoArr = [Dictionary<String,String>]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getStatusInfoArr()
        servicesInformationTV.dataSource = self
        servicesInformationTV.delegate = self
        
        if isDriver{
            let originalImage = UIImage.init(named: "ic_settings_phone")
            let templateImage = originalImage?.withRenderingMode(.alwaysTemplate)
            subImg.image = templateImage
            subImg.tintColor = UIColor.GrayAsRemis
            infoLbl.textColor = UIColor.GrayAsRemis
            
            let originalImage2 = UIImage.init(named: "ic_pin_drop")
            let templateImage2 = originalImage2?.withRenderingMode(.alwaysTemplate)
            subImg2.image = templateImage2
            subImg2.tintColor = UIColor.GrayAsRemis
            subLbl2.textColor = UIColor.GrayAsRemis
        }else{
            mainImg.isHidden = true
            subImg.isHidden = true
            infoLbl.isHidden = true
            subImg2.isHidden = true
            subLbl2.isHidden = true
            viewForDriverHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
        
        NotificationCenter.default.addObserver( self, selector: #selector(self.updateView),name: NSNotification.Name(updateViewByTrip), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getStatusInfoArr(){
        statusInfoArr = [Dictionary<String,String>]()
        if isDriver{
            statusInfoArr.append(["title":"Sin información", "icon":"ic_query_builder_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_directions_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_pin_drop"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_error"])
        }else{
            statusInfoArr.append(["title":"Sin información", "icon":"ic_query_builder_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_directions_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_query_builder_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_settings_phone_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_directions_car_48pt"])
   
        }
    }
    
    @objc func updateView(notification: NSNotification){
        infoLbl.text = SingletonsObject.sharedInstance.currentTrip?.phoneClient
        subLbl2.text = SingletonsObject.sharedInstance.currentTrip?.nameOrigin
        statusInfoArr = [Dictionary<String,String>]()
        if isDriver{
            var multiOrigin = ""
            multiOrigin.append("1)")
            multiOrigin.append(SingletonsObject.sharedInstance.currentTrip?.OriginMultiple1?.name ?? "No Pose")
            multiOrigin.append(" - 2)")
            multiOrigin.append(SingletonsObject.sharedInstance.currentTrip?.OriginMultiple2?.name ?? "No Pose")
            multiOrigin.append(" - 3)")
            multiOrigin.append(SingletonsObject.sharedInstance.currentTrip?.OriginMultiple3?.name ?? "No Pose")
            multiOrigin.append(" - 4)")
            multiOrigin.append(SingletonsObject.sharedInstance.currentTrip?.OriginMultiple4?.name ?? "No Pose")
            
            statusInfoArr.append(["title":(SingletonsObject.sharedInstance.currentTrip?.pasajero) ?? "", "icon":"ic_airline_seat_recline_normal_48pt"])
            statusInfoArr.append(["title":(SingletonsObject.sharedInstance.currentTrip?.dateTravel) ?? "", "icon":"ic_query_builder_48pt"])
            statusInfoArr.append(["title":multiOrigin, "icon":"ic_directions_48pt"])
            statusInfoArr.append(["title":(SingletonsObject.sharedInstance.currentTrip?.nameOrigin) ?? "", "icon":"ic_pin_drop"])
            statusInfoArr.append(["title":(SingletonsObject.sharedInstance.currentTrip?.obsertavtionFlight) ?? "", "icon":"ic_airplanemode_active_48pt"])
            statusInfoArr.append(["title":(SingletonsObject.sharedInstance.currentTrip?.observationFromDriver) ?? "", "icon":"ic_error"])
        }else{
            statusInfoArr.append(["title":"Sin información", "icon":"ic_query_builder_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_directions_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_query_builder_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_settings_phone_48pt"])
            statusInfoArr.append(["title":"Sin información", "icon":"ic_directions_car_48pt"])
            
        }
        servicesInformationTV.reloadData()
    }
    

}
extension ServicesActionsDetailViewController:  UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statusInfoArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServicesCell", for: indexPath)
        let imgIcon = cell.viewWithTag(101) as! UIImageView
        let lblTitle = cell.viewWithTag(102) as! UILabel
        
        lblTitle.text = statusInfoArr[indexPath.row]["title"]!
        lblTitle.textColor = UIColor.GrayAsRemis
        let originalImage = UIImage(named: statusInfoArr[indexPath.row]["icon"]!)
        let templateImage = originalImage?.withRenderingMode(.alwaysTemplate)
        imgIcon.image = templateImage
        imgIcon.tintColor = UIColor.GrayAsRemis
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

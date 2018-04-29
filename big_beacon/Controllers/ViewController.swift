//
//  ViewController.swift
//  big_beacon
//
//  Created by constantin guidon on 26/04/2018.
//  Copyright © 2018 constantin guidon. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var qrCode: String? = nil
    let manager = CLLocationManager()
    let apiClient = APIClient(Constants.backEndUrl)
    
    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var scanQrCodeButton: UIButton!
    @IBOutlet weak var courseLocation: UILabel!
    @IBOutlet weak var courseTime: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        checkToken()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let qrCode = appDelegate?.qrCode {
            self.qrCode = qrCode
            checkInButton.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLocationInfos()
        checkInButton.isHidden = true
        manager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkIn(_ sender: Any) {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            manager.requestWhenInUseAuthorization()
        }else{
            startRanging()
        }
    }
    
    @IBAction func showScanner(_ sender: Any) {
        if let next = self.storyboard?.instantiateViewController(withIdentifier: "QrCodeController") as? QRCodeController {
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    private func checkToken() {
        if let token = Helper.getToken() {
            refreshToken(token:token)
        } else {
          redirectToLogin()
        }
    }
    
    private func getLocationInfos(){
        apiClient.getLocationInfos().responseJSON { response in
            guard response.result.error == nil, let json = response.result.value as? [String: Any] else {
                // TODO : Handle Error
                return
            }
            self.courseTime.text = json["date"] as? String
            self.courseLocation.text = json["location"] as? String
        }
    }
    
    //https://grokswift.com/rest-with-alamofire-swiftyjson/
    private func refreshToken(token : String) {
        apiClient.refreshToken(["token": token])
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    self.redirectToLogin()
                    return
                }
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    self.redirectToLogin()
                    return
                }
                // get and print the title
                guard let token = json["token"] as? String else {
                    self.redirectToLogin()
                    return
                }
                Helper.storeToken(token)
        }
    }
    
    private func buildCheckInDict(_ beacons: [CLBeacon]) -> Dictionary<String,Any> {
        let beaconsCollection : Array<Int> = beacons.map { $0.major.intValue + $0.minor.intValue }
        return ["token": Helper.getToken()!, "date":"", "QRCodeData" : qrCode!,"beaconCollection":beaconsCollection] as [String : Any]
    }
    
    private func redirectToLogin(){
        if let next = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    fileprivate func startRanging(){
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString:"F2A74FC4-7625-44DB-9B08-CB7E130B2029")!, identifier: "premier")
        manager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            let data = buildCheckInDict(beacons)
            apiClient.checkIn(data).responseJSON { response in
                guard response.result.error == nil else {                                                 // check for fundamental networking error
                    return
                }
                manager.stopRangingBeacons(in: region)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startRanging()
        }
    }
    
}


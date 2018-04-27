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

    @IBOutlet weak var checkInButton: UIButton!
    @IBOutlet weak var scanQrCodeButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        //checkToken()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let qrCode = appDelegate?.qrCode {
            self.qrCode = qrCode
            checkInButton.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        // https://stackoverflow.com/questions/31203241/how-can-i-use-userdefaults-in-swift
        if let token = Helper.getToken() {
            refreshToken(token:token)
        } else {
          redirectToLogin()
        }
    }
    
    //https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
    private func refreshToken(token : String) {
        let url = URL(string: "\(Constants.backEndUrl)/api/refreshToken")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token], options: [])
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                self.redirectToLogin()
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                self.redirectToLogin()
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                let token = json["token"]
                Helper.storeToken(token as! String)
            } catch let error as NSError {
                print(error)
                self.redirectToLogin()
            }
            
        }
        task.resume()
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
            let beaconsCollection : Array<Int> = beacons.map { Int($0.major) + Int($0.minor) }
            let url = URL(string: "\(Constants.backEndUrl)/api/checkIn")!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let dict = ["token": Helper.getToken()!, "date":"", "QRCodeData" : qrCode,"beaconCollection":beaconsCollection] as [String : Any]
            request.httpBody = try? JSONSerialization.data(withJSONObject:dict , options: [])
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                // Do stuff with response
                // 
            }
            task.resume()
            manager.stopRangingBeacons(in: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            startRanging()
        }
    }
    
}


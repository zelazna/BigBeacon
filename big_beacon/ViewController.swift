//
//  ViewController.swift
//  big_beacon
//
//  Created by constantin guidon on 26/04/2018.
//  Copyright © 2018 constantin guidon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func showScanner(_ sender: Any) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkToken()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkToken() {
        // https://stackoverflow.com/questions/31203241/how-can-i-use-userdefaults-in-swift
        if let token = UserDefaults.standard.string(forKey: "token") {
            refreshToken(token:token)
        } else {
          redirectToLogin()
        }
    }
    
    //https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
    func refreshToken(token : String) {
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
    
    func redirectToLogin(){
        if let next = self.storyboard?.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
            self.navigationController?.pushViewController(next, animated: true)
        }
        
    }

}


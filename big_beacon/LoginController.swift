//
//  LoginController.swift
//  big_beacon
//
//  Created by Sara on 27/04/2018.
//  Copyright © 2018 constantin guidon. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var connexionView: UIView!
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var errorMsg: UIView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var buttonGo: UIButton!
    
    func removeErrorMsg(){
        DispatchQueue.main.async {
            self.errorMsg.layer.cornerRadius = 5
            self.errorMsg.layer.backgroundColor = UIColor(red: 0.84705, green: 0.27843, blue: 0.15294, alpha: 0).cgColor
            self.errorMsgLabel.textColor = UIColor(red: 0.84705, green: 0.27843, blue: 0.15294, alpha: 0)
        }
    }
    
    func displayErrorMsg(){
        DispatchQueue.main.async {
            self.errorMsg.layer.cornerRadius = 5
            self.errorMsg.layer.backgroundColor = UIColor(red: 0.84705, green: 0.27843, blue: 0.15294, alpha: 0.3).cgColor
            self.errorMsgLabel.textColor = UIColor(red: 0.84705, green: 0.27843, blue: 0.15294, alpha: 1)
        }
    }
    
    
    @IBAction func connect(_ sender: Any) {
        let id = userId.text
        let password = userPassword.text
        if userId.text == nil {
            print("no ID")
            self.displayErrorMsg()
        }
        else if userPassword == nil {
            print("no password")
            self.displayErrorMsg()
        }
        else {
            let session = URLSession.shared
            let u = URL(string:"http://localhost:3000/api/login")
            var request = URLRequest(url: u!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: ["Email": id, "Password": password], options: [])
            
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {                                                 // check for fundamental networking error
                    print("error=\(String(describing: error))")
                    self.displayErrorMsg()
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                    self.displayErrorMsg()
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    let token = json["token"]
                    Helper.storeToken(token as! String)
                } catch let error as NSError {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    @IBAction func redirectToCheckIn(_ sender: Any) {
        if let next = self.storyboard?.instantiateViewController(withIdentifier: "CheckIn") as? ViewController {
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeErrorMsg()
        
        connexionView.layer.cornerRadius = 5
        connexionView.layer.shadowColor = UIColor.black.cgColor
        connexionView.layer.shadowOpacity = 0.3
        connexionView.layer.shadowOffset = CGSize.zero
        connexionView.layer.shadowRadius = 10
        buttonGo.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        buttonGo.layer.cornerRadius = 15
        buttonGo.layer.backgroundColor = UIColor(red: 1, green: 0.92941, blue: 0, alpha: 1).cgColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

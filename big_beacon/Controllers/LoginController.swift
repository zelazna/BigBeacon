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
    @IBOutlet weak var buttonGo: UIMainButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    func displayModal(){
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
            self.connexionView.alpha = 1
            self.titleLabel.alpha = 1
            self.userId.alpha = 1
            self.userPassword.alpha = 1
            self.buttonGo.alpha = 1
            self.connexionView.layer.cornerRadius = 5
            self.connexionView.layer.shadowColor = UIColor.black.cgColor
            self.connexionView.layer.shadowOpacity = 0.3
            self.connexionView.layer.shadowOffset = CGSize.zero
            self.connexionView.layer.shadowRadius = 10
            self.buttonGo.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            self.buttonGo.layer.cornerRadius = 15
            self.buttonGo.layer.backgroundColor = UIColor(red: 1, green: 0.92941, blue: 0, alpha: 1).cgColor
        }) { (success: Bool) in
            if success {
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                    self.connexionView.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
                }) { (success: Bool) in
                    if success {
                        UIView.animate(withDuration: 0.1, animations: {
                            self.connexionView.transform = CGAffineTransform.identity
                        })
                    }
                }
            }
        }
    }
    
    func removeErrorMsg(){
        DispatchQueue.main.async {
            self.errorMsg.layer.cornerRadius = 5
            self.errorMsg.layer.backgroundColor = UIColor(red: 0.84705, green: 0.27843, blue: 0.15294, alpha: 0).cgColor
            self.errorMsgLabel.textColor = UIColor(red: 0.84705, green: 0.27843, blue: 0.15294, alpha: 0)
        }
    }
    
    func displayErrorMsg(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.errorMsg.layer.cornerRadius = 5
                self.errorMsg.layer.backgroundColor = UIColor(red: 0.84705, green: 0.27843, blue: 0.15294, alpha: 0.3).cgColor
            })
            UIView.animate(withDuration: 1, delay: 0.9, animations: {
              self.errorMsgLabel.textColor = UIColor(red: 0.84705, green: 0.27843, blue: 0.15294, alpha: 1)
            })
        }
    }
    

    func buttonAnimation(){
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonGo.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { (success: Bool) in
            if success {
                UIView.animate(withDuration: 0.1, animations: {
                    self.buttonGo.transform = CGAffineTransform.identity
                })
            }
        }
    }
    
    @IBAction func connect(_ sender: Any) {
        self.buttonAnimation()
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
            let u = URL(string:"\(Constants.backEndUrl)/api/login")
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
                    self.redirectToCheckIn()
                } catch let error as NSError {
                    print(error)
                }
            }
            task.resume()
        }
    }
    
    private func redirectToCheckIn() {
        if let next = self.storyboard?.instantiateViewController(withIdentifier: "CheckIn") as? ViewController {
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.removeErrorMsg()
        connexionView.alpha = 0
        titleLabel.alpha = 0
        userId.alpha = 0
        userPassword.alpha = 0
        buttonGo.alpha = 0
        self.displayModal()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

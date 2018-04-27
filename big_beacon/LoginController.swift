//
//  LoginController.swift
//  big_beacon
//
//  Created by Sara on 27/04/2018.
//  Copyright © 2018 constantin guidon. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    
    @IBAction func connect(_ sender: Any) {
        let id = userId.text
        let password = userPassword.text
        if userId.text == nil { print("no ID") }
        else if userPassword == nil { print("no password") }
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
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
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

//
//  Helper.swift
//  big_beacon
//
//  Created by constantin guidon on 26/04/2018.
//  Copyright © 2018 constantin guidon. All rights reserved.
//

import Foundation

class Helper{
    // https://stackoverflow.com/questions/31203241/how-can-i-use-userdefaults-in-swift
    
    static func storeToken(_ token : String) {
        UserDefaults.standard.set(token, forKey: "token")
    }
    
    static func getToken()-> String?{
        return UserDefaults.standard.string(forKey: "token")
    }
}

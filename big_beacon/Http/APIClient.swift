//
//  APIClient.swift
//  big_beacon
//
//  Created by constantin guidon on 29/04/2018.
//  Copyright © 2018 constantin guidon. All rights reserved.
//

import Foundation
import Alamofire

class APIClient {
    var base :String? = nil
    
    init(_ baseUrl: String){
        base = baseUrl
    }
    
    func refreshToken(_ token: Dictionary<String,Any>) ->DataRequest{
        return Alamofire.request(
            "\(base!)/api/refreshToken",
            method: .post,
            parameters: token,
            encoding: JSONEncoding.default
        )
    }
    
    func getLocationInfos() ->DataRequest {
        return Alamofire.request("\(base!)/api/getLocation")
    }
    
    func checkIn(_ data: Dictionary<String, Any>) ->DataRequest {
        return Alamofire.request(
            "\(base!)/api/checkIn",
            method: .post,
            parameters: data,
            encoding: JSONEncoding.default
        )
    }
}

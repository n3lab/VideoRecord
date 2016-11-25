//
//  LoginAPI.swift
//  VideoRecord
//
//  Created by n3deep on 23.11.16.
//  Copyright © 2016 n3deep. All rights reserved.
//

import Alamofire
import SwiftyJSON
import SwiftSpinner

class LoginAPI {

    class func getToken(username: String, password: String, onSuccess: @escaping (String) -> Void, onFailed: @escaping (Int) -> Void) {
        SwiftSpinner.show("Заходим...")
        Alamofire.request("\(authURL)/oauth/token", method: .post, parameters: ["grant_type": "password", "username": username, "password": password]).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                let json = JSON(response.result.value!)
                print(json)
                Utils.setDateOfTokenExpiration(seconds: json["expires_in"].int!)
                onSuccess(json["access_token"].string!)
                SwiftSpinner.hide()
            case .failure(let error):
                print(error)
                let errorCode = (response.response?.statusCode)! as Int
                onFailed(errorCode)
                SwiftSpinner.hide()
            }
        }
    }
    
}

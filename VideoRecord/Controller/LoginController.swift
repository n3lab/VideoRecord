//
//  LoginController.swift
//  VideoRecord
//
//  Created by n3deep on 23.11.16.
//  Copyright © 2016 n3deep. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        LoginAPI.getToken(username: loginTextField.text!, password: passwordTextField.text!, onSuccess: {accessToken in
            print(accessToken)
            Utils.setTokenFromKeychain(token: accessToken)
            self.performSegue(withIdentifier: "ShowRecordController", sender: self)
        }, onFailed: {errorMessageCode in
            print(errorMessageCode)
            MessageGenerator.generateMessage(errorCode: errorMessageCode, controller: self)
        })
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

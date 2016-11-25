//
//  ErrorMessage.swift
//  VideoRecord
//
//  Created by n3deep on 23.11.16.
//  Copyright © 2016 n3deep. All rights reserved.
//

import UIKit
import Foundation

class Message {
    class func showMessage(messageString: String, controller: UIViewController) {
        let alert = UIAlertController(title: "Сообщение",
                                      message: messageString,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        controller.present(alert, animated: true, completion: nil)
    }
}

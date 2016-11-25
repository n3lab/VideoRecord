//
//  BaseAPI.swift
//  VideoRecord
//
//  Created by n3deep on 23.11.16.
//  Copyright © 2016 n3deep. All rights reserved.
//

import Alamofire
import SwiftyJSON
import SwiftSpinner

class BaseAPI {
    class func uploadMediaContent(access_token: String, name: String, type_content: String, fileData: Data, onSuccess: @escaping (Int) -> Void, onFailed: @escaping (Int) -> Void) {
        SwiftSpinner.show("Заходим на сервер...")
        
        let token = Utils.getTokenFromKeychain() as String
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "multipart/form-data"
            ]
        
        let parameters = [
            "name": name,
            "type_content": type_content,
        ]

        Alamofire.upload( multipartFormData: { multipartFormData in
                multipartFormData.append(fileData, withName: "video", fileName: name, mimeType: "video/mp4")
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
        },
            to: "\(baseURL)/content/add", headers: headers,
            encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (progress) in
                        print(progress)
                        SwiftSpinner.show(progress: progress.fractionCompleted, title: "Загружаем видео...")
                        if progress.fractionCompleted == 1 {
                            SwiftSpinner.show("Получаем ответ с сервера")
                        }
                    })
                    upload.validate().responseJSON { response in
                        let json = JSON(response.result.value!)
                        print(json)
                        print("status \(json["status"])")
                        let status = json["status"]
                        guard status == "SUCCESS" else {
                            //здесь смотрим errorMessageList с текстом ошибки
                            onSuccess(5000)
                            SwiftSpinner.hide()
                            return
                        }
                        
                        onSuccess(4001)
                        SwiftSpinner.hide()
                    }
                case .failure(let error):
                    print(error)
                    SwiftSpinner.hide()
                }
        }
        )
    }
}

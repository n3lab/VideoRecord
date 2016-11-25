//
//  ErrorGenerator.swift
//  VideoRecord
//
//  Created by n3deep on 23.11.16.
//  Copyright © 2016 n3deep. All rights reserved.
//

import UIKit
import Foundation

class MessageGenerator {
    class func generateMessage(errorCode: Int, controller: UIViewController) {
        switch errorCode {
        case 401:
            Message.showMessage(messageString: "Неверный логин или пароль", controller: controller)
        
        case 2000:
            Message.showMessage(messageString: "Ошибка", controller: controller)
        case 2001:
            Message.showMessage(messageString: "Ошибка при объединении файлов", controller: controller)
            
        case 2010:
            Message.showMessage(messageString: "Не удалось загрузить первое видео", controller: controller)
        case 2011:
            Message.showMessage(messageString: "Не удалось загрузить второе видео", controller: controller)
        case 2012:
            Message.showMessage(messageString: "Объединенного видео нету.", controller: controller)
            
        case 3000:
            Message.showMessage(messageString: "У приложения нет доступа к камере", controller: controller)
        case 3001:
            Message.showMessage(messageString: "Задняя камера не существует", controller: controller)
        
        case 4000:
            Message.showMessage(messageString: "Видео объеденены", controller: controller)
        case 4001:
            Message.showMessage(messageString: "Общее видео отправлено на сервер!", controller: controller)
            
        case 5000:
            Message.showMessage(messageString: "Ошибка с описанием.", controller: controller)
            
        default:
            Message.showMessage(messageString: "Ошибка сервера!", controller: controller)
        }
    }
}

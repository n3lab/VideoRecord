//
//  UploadController.swift
//  VideoRecord
//
//  Created by n3deep on 23.11.16.
//  Copyright © 2016 n3deep. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVKit
import AVFoundation
import SwiftSpinner
import Photos

class RecordController: UIViewController {

    let imagePicker: UIImagePickerController! = UIImagePickerController()
    let firstVideoName = "video1.mp4"
    let secondVideoName = "video2.mp4"
    let mergedVideoName = "mergeVideo.mp4"
    var currentVideoName = String()
    var videoModification = VideoModification()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //temp
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            print(directoryContents)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordFirstVideoButtonPressed(_ sender: Any) {
        currentVideoName = firstVideoName
        self.recordVideo()
    }

    @IBAction func showFirstVideoButtonPressed(_ sender: Any) {
        
        self.playVideoWithName(name: firstVideoName)
    }

    @IBAction func recordSecondVideoButtonPressed(_ sender: Any) {
        currentVideoName = secondVideoName
        self.recordVideo()
    }
    
    @IBAction func showSecondVideoButtonPressed(_ sender: Any) {
        self.playVideoWithName(name: secondVideoName)
    }
    
    @IBAction func mergeVideosButtonPressed(_ sender: Any) {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: (Utils.getDocumentsDirectory().appendingPathComponent(firstVideoName)).path) else {
            return MessageGenerator.generateMessage(errorCode: 2010, controller: self)
        }
        guard fileManager.fileExists(atPath: (Utils.getDocumentsDirectory().appendingPathComponent(secondVideoName)).path) else {
            return MessageGenerator.generateMessage(errorCode: 2011, controller: self)
        }
        
        let firstAsset = AVAsset(url: Utils.getDocumentsDirectory().appendingPathComponent(firstVideoName)) as AVAsset
        let secondAsset = AVAsset(url: Utils.getDocumentsDirectory().appendingPathComponent(secondVideoName)) as AVAsset
        
        videoModification.mergeVideos(firstVideoAsset: firstAsset, secondVideoAsset: secondAsset, mergedVideoName: mergedVideoName,   onSuccess: { messageCode in
            print("Merged success")
            MessageGenerator.generateMessage(errorCode: messageCode, controller: self)
        }, onFailed: { errorCode in
            MessageGenerator.generateMessage(errorCode: errorCode, controller: self)
        })
    }

    @IBAction func showMergedVideoButtonPressed(_ sender: Any) {
        self.playVideoWithName(name: mergedVideoName)
    }
  
    @IBAction func sendVideoButtonPressed(_ sender: Any) {
        let dataPath =  Utils.getDocumentsDirectory().appendingPathComponent(mergedVideoName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: dataPath.path) {
            guard let videoData = try? Data(contentsOf: dataPath) else {
                return MessageGenerator.generateMessage(errorCode: 2000, controller: self)
            }
            
            BaseAPI.uploadMediaContent(access_token: Utils.getTokenFromKeychain(), name: mergedVideoName, type_content: "VIDEO", fileData: videoData, onSuccess: { successCode in
                MessageGenerator.generateMessage(errorCode: successCode, controller: self)
            }, onFailed: { failed in
                print("error")
            })
        } else {
            return MessageGenerator.generateMessage(errorCode: 2012, controller: self)
        }
    }
    
}

extension RecordController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedVideo:URL = (info[UIImagePickerControllerMediaURL] as? URL) {
            
            //сохранить в фотоальбом
            let selectorToCall = #selector(RecordController.videoWasSavedSuccessfully(_:didFinishSavingWithError:context:))
            UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath, self, selectorToCall, nil)
            
            
            let dataPath =  Utils.getDocumentsDirectory().appendingPathComponent(currentVideoName)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: dataPath.path) {
                do {
                    try fileManager.removeItem(atPath: dataPath.path)
                }
                catch let error as NSError {
                    print("error: \(error)")
                }
            }
            
            let videoData = try? Data(contentsOf: pickedVideo)
            try? videoData?.write(to: dataPath)
            
        }
        
        imagePicker.dismiss(animated: true, completion: {
            //сохранено
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User canceled image")
        dismiss(animated: true, completion: {
            //отменено
        })
    }
    
    func videoWasSavedSuccessfully(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        print("Видео сохранено")
        if let theError = error {
            print("error = \(theError)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                // сохранено
            })
        }
    }
    
    //record
    func recordVideo() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeMovie as String]
                imagePicker.allowsEditing = false
                imagePicker.delegate = self
                
                present(imagePicker, animated: true, completion: {})
            } else {
                MessageGenerator.generateMessage(errorCode: 3001, controller: self)
            }
        } else {
            MessageGenerator.generateMessage(errorCode: 3000, controller: self)
        }
    }
    
    //play
    func playVideoWithName(name: String) {
        let dataPath = Utils.getDocumentsDirectory().appendingPathComponent(name)
        let videoAsset = (AVAsset(url: dataPath))
        let playerItem = AVPlayerItem(asset: videoAsset)
        
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}


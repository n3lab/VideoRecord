//
//  VideoModification.swift
//  VideoRecord
//
//  Created by n3deep on 24.11.16.
//  Copyright © 2016 n3deep. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftSpinner
import Photos

class VideoModification {

    //merge
    func mergeVideos(firstVideoAsset: AVAsset, secondVideoAsset: AVAsset, mergedVideoName: String, onSuccess: @escaping (Int) -> Void, onFailed: @escaping (Int) -> Void) {
        SwiftSpinner.show("Объединяем два видео...")
        let firstAsset = firstVideoAsset
        let secondAsset = secondVideoAsset
        
        let mixComposition = AVMutableComposition()
        
        let firstTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try firstTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, firstAsset.duration), of: firstAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: kCMTimeZero)
        } catch _ {
            SwiftSpinner.hide()
            return onFailed(2010)
        }
        
        let secondTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            try secondTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, secondAsset.duration), of: secondAsset.tracks(withMediaType: AVMediaTypeVideo)[0], at: firstAsset.duration)
        } catch _ {
            SwiftSpinner.hide()
            return onFailed(2011)
        }
        
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration))
        
        let firstInstruction = videoCompositionInstructionForTrack(firstTrack, asset: firstAsset)
        firstInstruction.setOpacity(0.0, at: firstAsset.duration)
        let secondInstruction = videoCompositionInstructionForTrack(secondTrack, asset: secondAsset)
        
        mainInstruction.layerInstructions = [firstInstruction, secondInstruction]
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        let url =  Utils.getDocumentsDirectory().appendingPathComponent(mergedVideoName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(atPath: url.path)
            }
            catch let error as NSError {
                print("error while deleting: \(error)")
                SwiftSpinner.hide()
                return onFailed(2000)
            }
        }
        
        guard let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = mainComposition
        
        exporter.exportAsynchronously() {
            DispatchQueue.main.async { _ in
                if exporter.status == AVAssetExportSessionStatus.completed {
                    print("merge completed")
                    //сохранить в альбом
                    PHPhotoLibrary.shared().performChanges({
                        _ = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exporter.outputURL!)
                    }) { success, error in
                        if success {
                            onSuccess(4000)
                        }
                    }
                }
                if exporter.status == AVAssetExportSessionStatus.failed {
                    print(exporter.error as Any)
                    onFailed(2001)
                }
                SwiftSpinner.hide()
                
            }
        }
    }
    
    //helper methods
    internal func videoCompositionInstructionForTrack(_ track: AVCompositionTrack, asset: AVAsset) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        
        if assetInfo.isPortrait {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor),
                                     at: kCMTimeZero)
        } else {
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.width / 2))
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            instruction.setTransform(concat, at: kCMTimeZero)
        }
        
        return instruction
    }
    
    internal func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }


}

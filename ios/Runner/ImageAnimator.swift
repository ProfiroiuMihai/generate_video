//
//  ImageAnimator.swift
//  ScreenshotSample
//
//  Created by Code Karkhana on 08/08/2023.
//


import Foundation
import AVFoundation
import UIKit
import Photos

struct RenderSettings {
    var size: CGSize = .zero
    var fps: Int32 = 30   // frames per second
    var avCodecKey = AVVideoCodecType.h264
    var videoFilename = "output"
    var videoFilenameExt = "mp4"
    var outputURL: URL {
        let fileManager = FileManager.default
        if let tmpDirURL = try? fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
            return tmpDirURL.appendingPathComponent(videoFilename).appendingPathExtension(videoFilenameExt)
        }
        fatalError("URLForDirectory() failed")
    }
}

class ImageAnimator {
    // Apple suggests a timescale of 600 because it's a multiple of standard video rates 24, 25, 30, 60 fps etc.
       static let kTimescale: Int32 = 600

       let settings: RenderSettings
       let videoWriter: VideoWriter

       var frameNum = 0

       init(renderSettings: RenderSettings) {
           settings = renderSettings
           videoWriter = VideoWriter(renderSettings: settings)
       }
    
    
    func startVideoWriting() {
           ImageAnimator.removeFileAtURL(fileURL: settings.outputURL)
           videoWriter.start()
       }
    
    /*
     to accept unit8list
     */
    
    func appendPixelData(_ pixelData: [UInt8]) {
        let frameDuration = CMTimeMake(value: Int64(ImageAnimator.kTimescale / settings.fps), timescale: ImageAnimator.kTimescale)
        let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameNum))
        
        let success = videoWriter.addPixelData(pixelData, withPresentationTime: presentationTime)
        
        if !success {
            fatalError("addPixelData() failed")
        }
        
        frameNum += 1
    }

    
    func appendImage(_ image: UIImage) {
        
            let frameDuration = CMTimeMake(value: Int64(ImageAnimator.kTimescale / settings.fps), timescale: ImageAnimator.kTimescale)
            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameNum))
            let success = videoWriter.addImage(image: image, withPresentationTime: presentationTime)
        
            if success == false {
                print("Adding images 123456")
                fatalError("addImage() failed")
            }
            print("Adding images12345")
            frameNum += 1
        }
    
    func finalizeVideo(completion: (() -> Void)?) {
        ImageAnimator.saveToLibrary(videoURL: settings.outputURL)
            videoWriter.finalize(completion: completion)
        }
    
    class func savePhoto(photoUrl: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: photoUrl)
            }) { success, error in
                if !success {
                    print("Could not save to photo library:", error as Any)
                }else{
                    print("saved photo to photo library:")
               
                }
            }
        }
    }
    
    class func saveToLibrary(videoURL: URL) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                return
            }

            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            }) { success, error in
                if !success {
                    print("Output URL:", videoURL)
                    print("Could not save video to photo library:", error as Any)
                }
            }
        }
    }

    class func removeFileAtURL(fileURL: URL) {
        do {
            try FileManager.default.removeItem(atPath: fileURL.path)
            print("I am calling remove url \(fileURL.path)")
        } catch _ as NSError {
            // Assume file doesn't exist.
        }
    }
}


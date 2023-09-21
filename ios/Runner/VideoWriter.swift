//
//  VideoWriter.swift
//  ScreenshotSample
//
//  Created by Code Karkhana on 09/08/2023.
//

import Foundation
import AVFoundation
import UIKit

class VideoWriter {
    let renderSettings: RenderSettings
       var videoWriter: AVAssetWriter!
       var videoWriterInput: AVAssetWriterInput!
       var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor!

       init(renderSettings: RenderSettings) {
           self.renderSettings = renderSettings
       }

    var isReadyForData: Bool {
        return videoWriterInput?.isReadyForMoreMediaData ?? false
    }
    
    func finalize(completion: (() -> Void)?) {
           videoWriterInput.markAsFinished()
           videoWriter.finishWriting {
               DispatchQueue.main.async {
                   completion?()
               }
           }
       }

      
    
    func start() {
          let avOutputSettings: [String: Any] = [
              AVVideoCodecKey: renderSettings.avCodecKey,
              AVVideoWidthKey: NSNumber(value: Float(renderSettings.size.width)),
              AVVideoHeightKey: NSNumber(value: Float(renderSettings.size.height))
          ]

          videoWriter = try! AVAssetWriter(outputURL: renderSettings.outputURL, fileType: AVFileType.mp4)
          videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: avOutputSettings)
          videoWriter.add(videoWriterInput)

          let sourcePixelBufferAttributesDictionary = [
              kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
              kCVPixelBufferWidthKey as String: NSNumber(value: Float(renderSettings.size.width)),
              kCVPixelBufferHeightKey as String: NSNumber(value: Float(renderSettings.size.height))
          ]
          pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput,
                                                                      sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)

          videoWriter.startWriting()
          videoWriter.startSession(atSourceTime: CMTime.zero)
      }

    /*
     direct image
     */
    class func pixelBufferFromImage(image: UIImage, size: CGSize) -> CVPixelBuffer {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            fatalError("CVPixelBufferCreate() failed")
        }

        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)

        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(size.width), height: Int(size.height),
                                bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))

        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))

        return pixelBuffer!
    }
 
    
    func addImage(image: UIImage, withPresentationTime presentationTime: CMTime) -> Bool {
           while !videoWriterInput.isReadyForMoreMediaData {
               usleep(10)
           }

           let pixelBuffer = VideoWriter.pixelBufferFromImage(image: image, size: renderSettings.size)
           return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
       }

    /*
     for unit8 list
     */
    
    class func pixelBufferFromPixelData(pixelData: [UInt8], size: CGSize) -> CVPixelBuffer {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess else {
            fatalError("CVPixelBufferCreate() failed")
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelDataBuffer = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelDataBuffer,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        // Copy pixel data into the pixel buffer
        if let data = context?.data {
            memcpy(data, pixelData, pixelData.count)
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer!
    }
    
    func addPixelData(_ pixelData: [UInt8], withPresentationTime presentationTime: CMTime) -> Bool {
        while !videoWriterInput.isReadyForMoreMediaData {
            usleep(10)
        }

        let pixelBuffer = VideoWriter.pixelBufferFromPixelData(pixelData: pixelData, size: renderSettings.size)
        return pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
    }


    
}

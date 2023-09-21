//
//  ViewController.swift
//  Runner
//
//  Created by Code Karkhana on 16/08/2023.
//

import UIKit

import Flutter

class ViewController: UIViewController {
    private var flutterViewController: FlutterViewController!
    
    private var isCapturing = false
       private var screenshotTimer: Timer?
       private var screenshotCounter = 0
       private let screenshotFPS: TimeInterval = 1.0 / 30.0
       private let captureDuration: TimeInterval = 10.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        flutterViewController = FlutterViewController()
        addChild(flutterViewController)
        view.addSubview(flutterViewController.view)
        flutterViewController.didMove(toParent: self)
        
        let channel = FlutterMethodChannel(name: "screenshot_channel", binaryMessenger: flutterViewController as! FlutterBinaryMessenger)
                channel.setMethodCallHandler { [weak self] call, result in
                    if call.method == "takeScreenshot" {
                        self?.startScreenshotCapture(completion: { imageList in
                            result(imageList)
                        })
                    } else {
                        result(FlutterMethodNotImplemented)
                    }
                }
    }
    
   
    private func startScreenshotCapture(completion: @escaping ([FlutterStandardTypedData]) -> Void) {
           guard !isCapturing else {
               return
           }

           isCapturing = true
           var imageList: [FlutterStandardTypedData] = []

           screenshotCounter = 0
           screenshotTimer = Timer.scheduledTimer(withTimeInterval: screenshotFPS, repeats: true) { [weak self] timer in
               guard let self = self else {
                   timer.invalidate()
                   return
               }

               if self.screenshotCounter >= Int(self.captureDuration / self.screenshotFPS) {
                   timer.invalidate()
                   self.isCapturing = false
                   completion(imageList)
                   return
               }

               self.takeScreenshot(completion: { image in
                   if let imageData = image?.jpegData(compressionQuality: 1.0) {
                       let typedData = FlutterStandardTypedData(bytes: imageData)
                       imageList.append(typedData)
                   }

                   self.screenshotCounter += 1
               })
           }
       }
    
    private func takeScreenshot(completion: @escaping (UIImage?) -> Void) {
           let bounds = UIScreen.main.bounds
           UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
           
           if let context = UIGraphicsGetCurrentContext() {
               flutterViewController.view.layer.render(in: context)
               let screenshot = UIGraphicsGetImageFromCurrentImageContext()
               UIGraphicsEndImageContext()
               completion(screenshot)
           } else {
               completion(nil)
           }
       }
}


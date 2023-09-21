import UIKit
import Flutter
import AVFoundation
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var flutterViewController: FlutterViewController!
    private var screenRecordingManager: ScreenRecordingManager?
    private var isCapturing = false
       private var screenshotTimer: Timer?
       private var screenshotCounter = 0
       private let screenshotFPS: TimeInterval = 1.0 / 30.0
       private let captureDuration: TimeInterval = 10.0
    
    
       var screenshotChannel: FlutterMethodChannel?
    
       var screenshotCount = 0
    
    var imageAnimator: ImageAnimator?
    var isFirst = true
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 1

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        // 2

        let _channelName = "screenshot_channel";

        let deviceChannel = FlutterMethodChannel(name: _channelName,
                                                 binaryMessenger: controller.binaryMessenger)
        // 3
        prepareMethodHandler(deviceChannel: deviceChannel)

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }



    private func prepareMethodHandler(deviceChannel: FlutterMethodChannel) {

        deviceChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
         
            
            if call.method == "startScreenshotCapture" {
                self.startScreenshotCapture(result: result)
              } else if call.method == "stopScreenshotCapture" {
                  self.stopScreenshotCapture()
//                  self.stopVideoRecording(result: result)
              } else if call.method == "startVideoRecording" {
                    self.startVideoRecording(result: result)
              } else if call.method == "addNewRgbImages"{
                
                let listData = call.arguments as! [Any]
                            let uintInt8List = listData.first as! FlutterStandardTypedData
                            let byte = [UInt8](uintInt8List.data)

                            do {
                                let imageData = Data(byte)
                                if let image = UIImage(data: imageData) {
                                    // Conversion to UIImage was successful
                                    self.addNewRgbImages(result: result, image: image)
                                } else {
                                    // Conversion to UIImage failed
                                    print("Error: Conversion to UIImage failed")
                                    result("Error: Conversion to UIImage failed")
                                }
                            } catch {
                                // Handle any errors that occur during Data conversion
                                print("Error: \(error)")
                                result("Error: \(error)")
                            }

            } else if call.method == "stopVideoRecording"{
                     self.stopVideoRecording(result: result)
            }
            else {

                     result(FlutterMethodNotImplemented)

            }

        })
    }
    
    

//    private func startRecording(result: @escaping FlutterResult) {
//      screenRecordingManager = ScreenRecordingManager()
//      screenRecordingManager?.startRecording()
//        print("Start recording")
//      result(nil)
//
//
//    }
//
//
//    private func stopRecording(result: @escaping FlutterResult) {
//        // Introduce a 5-second delay using DispatchQueue.asyncAfter
//            self.screenRecordingManager?.stopRecording { recordedOutputURL in
//                if let finalURL = recordedOutputURL {
//                    print("Recording finished123: \(finalURL)")
//                    if let nsURL = recordedOutputURL as NSURL? {
//                       let swiftURL = nsURL as URL
//                        print("Recording finished1234: \(swiftURL)")
//                            self.saveToLibrary(videoURL: swiftURL)
//
//                        // Use swiftURL as needed
//                    }
//
//
//                    result("Recording success")
//                } else {
//                    print("Recording failed to finish.")
//                    result("Recording failed to finish.")
//                }
//            }
//
//    }

    
    func saveToLibrary(videoURL: URL) {
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
    
    
    func startScreenshotCapture(result: @escaping FlutterResult) {
          screenshotCount = 0
          screenshotTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true) { [weak self] timer in
              if let controller = self?.window?.rootViewController as? FlutterViewController,
                 let view = controller.view,
                 let screenshotImage = self?.captureScreenshot(from: view) {
//                  if let screenshotData = screenshotImage.jpegData(compressionQuality: 1.0) {
                      self?.addNewRgbImages(result: result, image: screenshotImage)
//                      self?.screenshotChannel?.invokeMethod("onScreenshotCaptured", arguments: screenshotData)
                      self?.screenshotCount += 1
                      if self?.screenshotCount == 720 { // Stop after 10 seconds (30fps * 10 seconds)
                          self?.stopScreenshotCapture()
                          self?.stopVideoRecording(result: result)
                      }
//                  }
              }
          }
          result(true)
      }
      
      func stopScreenshotCapture() {
          screenshotTimer?.invalidate()
          screenshotChannel?.invokeMethod("onScreenshotCaptureStopped", arguments: nil)
      }
    
    func captureScreenshot(from view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        
        // Set the background color to match your view's background color
        view.backgroundColor?.set()
        UIRectFill(view.bounds)
        
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshotImage
    }


      
//      func captureScreenshot(from view: UIView) -> UIImage? {
//          let scale = UIScreen.main.scale
//          UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, scale)
//          view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
//          let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
//          UIGraphicsEndImageContext()
//          return screenshotImage
//      }
    
    

    private func startVideoRecording(result: FlutterResult) {
       
         result("Started Device Recording")

    }


    private func addNewRgbImages(result: FlutterResult, image: UIImage){
        
        if isFirst {
            let renderSettings = RenderSettings(size: CGSize(width: image.size.width, height: image.size.height))
               imageAnimator = ImageAnimator(renderSettings: renderSettings)
               imageAnimator?.startVideoWriting()
            imageAnimator?.appendImage(image)
            isFirst = false
        }else{
            imageAnimator?.appendImage(image)
        }

        result("successfully added")
    }


    private func stopVideoRecording(result : FlutterResult){

        imageAnimator?.finalizeVideo {

             print("Video rendering completed")
        }

        result(self.imageAnimator?.settings.outputURL.absoluteString)
        imageAnimator = nil // Release the ImageAnimator


    }

    
}


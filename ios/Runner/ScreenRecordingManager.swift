//
//  ScreenRecordingManager.swift
//  Runner
//
//  Created by Code Karkhana on 16/08/2023.
//

import Foundation
import AVFoundation
import UIKit

class ScreenRecordingManager: NSObject, AVCaptureFileOutputRecordingDelegate {
    private var captureSession: AVCaptureSession?
    private var movieOutput: AVCaptureMovieFileOutput?
    private var outputFileURL: URL?
    var recordedOutputURL: URL?
    
    typealias RecordingCompletion = (URL?) -> Void

    
    func startRecording() {
        DispatchQueue.global(qos: .userInitiated).async { [self] in
               self.captureSession = AVCaptureSession()
               
               // Set up the input (screen capture)
               guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
               do {
                   let screenInput = try AVCaptureDeviceInput(device: captureDevice)
                   if self.captureSession?.canAddInput(screenInput) == true {
                       self.captureSession?.addInput(screenInput)
                   }
               } catch {
                   print("Error setting up AVCaptureDeviceInput: \(error)")
                   return
               }
               
               // Set up the output (movie file)
               self.movieOutput = AVCaptureMovieFileOutput()
            
               var videoCodecType: AVVideoCodecType
               if #available(iOS 13.0, *) {
                   videoCodecType = .hevc
               } else {
                   videoCodecType = .h264
               }

               let videoSettings: [String: Any] = [
                   AVVideoCodecKey: AVVideoCodecType.h264,
                   AVVideoWidthKey: NSNumber(value: Float(720)),
                   AVVideoHeightKey: NSNumber(value: Float(1280))
                   // Add other video settings as needed
               ]

            // Start the capture session
            self.captureSession?.startRunning()
            
            if let videoConnection = self.movieOutput?.connection(with: .video) {
                self.movieOutput?.setOutputSettings(videoSettings, for: videoConnection)
               }
             
               
               if self.captureSession?.canAddOutput(self.movieOutput!) == true {
                   self.captureSession?.addOutput(self.movieOutput!)
               }
               
              
               
               // Set the output file URL
               let tempDir = NSTemporaryDirectory()
               self.outputFileURL = URL(fileURLWithPath: tempDir).appendingPathComponent("screen_recording.mp4")
               print("Recording Started \(outputFileURL)")
//            self.recordedOutputURL = outputFileURL
               // Start recording to the output file
               self.movieOutput?.startRecording(to: self.outputFileURL!, recordingDelegate: self)
           }
       }
    
    
   
    
    // AVCaptureFileOutputRecordingDelegate methods
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Recording started
//
    }
    
    
    func stopRecording(completion: @escaping RecordingCompletion) {
            movieOutput?.stopRecording()
            captureSession?.stopRunning()
        print("Recording stopped \(recordedOutputURL)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [self] in
            print("Recording stopped \(recordedOutputURL)")
            completion(recordedOutputURL)
        }
            
        }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            // Recording finished with an error
            print("Recording error: \(error.localizedDescription)")
        } else {
            // Recording finished successfully
            recordedOutputURL = outputFileURL
            print("Recording finished: \(recordedOutputURL)")
        }
    }
}


//
//  SwiftScreenRecordingPlugin.swift
//  Runner
//
//  Created by Code Karkhana on 16/08/2023.
//

import Flutter
import UIKit
import AVFoundation

public class SwiftScreenRecordingPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
        name: "screen_recording_channel",
        binaryMessenger: registrar.messenger())
    let instance = SwiftScreenRecordingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    switch call.method {
//    case "startRecording":
////      startRecording(result: result)
//    case "stopRecording":
////      stopRecording(result: result)
//    default:
//      result(FlutterMethodNotImplemented)
//    }
  }

  private var screenRecordingManager: ScreenRecordingManager?

//  private func startRecording(result: @escaping FlutterResult) {
//    screenRecordingManager = ScreenRecordingManager()
//    screenRecordingManager?.startRecording()
//    result(nil)
//  }

//  private func stopRecording(result: @escaping FlutterResult) {
//
//      screenRecordingManager?.stopRecording { recordedOutputURL in
//          if let finalURL = recordedOutputURL {
//              print("Recording finished: \(finalURL)")
//              result("Recording finished")
//          } else {
//              print("Recording failed to finish.")
//              result("Recording failed to finish.")
//          }
//      }
//  }
}


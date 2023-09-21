import 'package:flutter/services.dart';

class ScreenRecordingPlugin {
  static const MethodChannel _channel =
  const MethodChannel('screen_recording_channel');

  static Future<void> startRecording() async {
    await _channel.invokeMethod('startRecording');
  }

  static Future<String> stopRecording() async {
    return await _channel.invokeMethod('stopRecording');
  }
}

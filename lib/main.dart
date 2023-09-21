// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_gif/flutter_gif.dart';
// import 'package:flutter_native_screenshot/flutter_native_screenshot.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:take_screenshots/videplay.dart';
//
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter GIF Example',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: VidePlay(),
//     );
//   }
// }
//
//
//
// class GifScreen extends StatefulWidget {
//   @override
//   _GifScreenState createState() => _GifScreenState();
// }
//
// class _GifScreenState extends State<GifScreen> with TickerProviderStateMixin {
//   late FlutterGifController _gifController;
//   final GlobalKey _repaintBoundaryKey = GlobalKey();
//   Timer? screenshotTimer;
//   final int screenshotDurationInSeconds = 150;
//   int elapsedTimeInSeconds = 0;
//   int imgCount = 0;
//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//       ),
//     );
//   }
//
//   Future<void> _doTakeScreenshot() async {
//
//     RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     final image = await boundary.toImage(pixelRatio: 3.5);
//     ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
//     Uint8List? uint8List = byteData?.buffer.asUint8List();
//     print("I am saving image $imgCount");
//     if (uint8List != null) {
//       final result = await ImageGallerySaver.saveImage(uint8List);
//       if (result['isSuccess']) {
//         print("I am saving image to gallery $imgCount");
//         imgCount += 1;
//         _showSnackBar('Screenshot saved to photo library');
//       } else {
//         _showSnackBar('Failed to save screenshot');
//       }
//     } else {
//       _showSnackBar('Failed to capture screenshot');
//     }
//   }
//
//   void _startScreenshotTimer() {
//     screenshotTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
//       _doTakeScreenshot();
//       elapsedTimeInSeconds++;
//       if (elapsedTimeInSeconds >= screenshotDurationInSeconds) {
//         _stopScreenshotTimer();
//       }
//     });
//   }
//
//   void _stopScreenshotTimer() {
//     screenshotTimer?.cancel();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _gifController = FlutterGifController(vsync: this);
//     _gifController.animateTo(57, duration: const Duration(seconds: 5));
//     _gifController.repeat(min: 0, max: 57, period: const Duration(seconds: 5));
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('GIF Display'),
//       ),
//       bottomNavigationBar: ButtonBar(
//         alignment: MainAxisAlignment.center,
//         children: <Widget>[
//           ElevatedButton(
//             child: const Text('Press to capture screenshot'),
//             onPressed: () async {
//               _startScreenshotTimer();
//             },
//           )
//         ],
//       ),
//       body: Center(
//         child: RepaintBoundary(
//           key: _repaintBoundaryKey,
//           child: GifImage(
//             fit: BoxFit.cover,
//             controller: _gifController,
//             image: AssetImage('assets/cat.gif'),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _stopScreenshotTimer(); // Stop the screenshot timer
//     _gifController.dispose();
//     super.dispose();
//   }
// }

// Inside your Dart code (main.dart or wherever appropriate)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:take_screenshots/videplay.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Screenshot Example',
      home: Scaffold(
        body: Center(
          child: VidePlay(),
        ),
      ),
    );
  }
}


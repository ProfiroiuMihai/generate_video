import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VidePlay extends StatefulWidget {
  const VidePlay({Key? key}) : super(key: key);

  @override
  State<VidePlay> createState() => _VidePlayState();
}

class _VidePlayState extends State<VidePlay> {
  final MethodChannel _methodChannel = MethodChannel('screenshot_channel');

  late VideoPlayerController _controller;
  bool _isPlaying = false;

  Future<void> _startScreenshotCapture() async {
    await Future.delayed(const Duration(milliseconds: 200)); // Delay for 0.2 seconds
    _controller.play(); // Start playing the video
    _methodChannel.invokeMethod('startScreenshotCapture');
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/input_video.mp4')
      ..initialize().then((_) {
        setState(() {
          _controller.setLooping(false);
          _isPlaying = false; // Start with the video paused
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            child: const Text('Press to start video and take screenshot'),
            onPressed: _startScreenshotCapture,
          )
        ],
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
              _isPlaying = false;
            } else {
              _controller.play();
              _isPlaying = true;
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

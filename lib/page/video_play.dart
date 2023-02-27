
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player_win/video_player_win.dart';

/// author : JiaBaoKang
/// e-mail : jiabaokangsy@gmail.com
/// date   : 2023/2/27 14:21
/// desc   :
///
class VideoPlay extends StatefulWidget {

  const VideoPlay({Key? key}) : super(key: key);

  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {

  WinVideoPlayerController? controller;

  void my_dispose() {
    controller?.dispose();
    controller = null;
  }

  void reload() {
    controller?.dispose();
    controller = WinVideoPlayerController.file(File("E:\\test_youtube.mp4"));
    controller!.initialize().then((value) {
      if (controller!.value.isInitialized) {
        controller!.play();
        setState(() {});
      } else {
        log("video file load failed");
      }
    }).catchError((e) {
      log("controller.initialize() error occurs: $e");
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('验证视频播放'),),
      body: Stack(children: [
        WinVideoPlayer(controller!),
        Positioned(
            bottom: 0,
            child: Column(children: [
              ValueListenableBuilder<WinVideoPlayerValue>(
                valueListenable: controller!,
                builder: ((context, value, child) {
                  int minute = value.position.inMinutes;
                  int second = value.position.inSeconds % 60;
                  return Text("$minute:$second",
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          color: Colors.white,
                          backgroundColor: Colors.black54));
                }),
              ),
              ElevatedButton(
                  onPressed: () => my_dispose(),
                  child: const Text("Dispose")),
              ElevatedButton(
                  onPressed: () => reload(), child: const Text("Reload")),
              ElevatedButton(
                  onPressed: () => controller?.play(),
                  child: const Text("Play")),
              ElevatedButton(
                  onPressed: () => controller?.pause(),
                  child: const Text("Pause")),
              ElevatedButton(
                  onPressed: () => controller?.seekTo(Duration(
                      milliseconds:
                      controller!.value.position.inMilliseconds -
                          10 * 1000)),
                  child: const Text("Backward")),
              ElevatedButton(
                  onPressed: () => controller?.seekTo(Duration(
                      milliseconds:
                      controller!.value.position.inMilliseconds +
                          10 * 1000)),
                  child: const Text("Forward")),
            ])),
      ]),

    );
  }
}

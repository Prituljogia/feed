import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoReels extends StatefulWidget {
  @override
  State<VideoReels> createState() => _VideoReelsState();
}

class _VideoReelsState extends State<VideoReels> {
  List<VideoPlayerController> _controllers = [];
  int _currentPageIndex = 0;
  List _items = [];

  Future<void> readJson() async {
    final String response = await rootBundle.loadString("json/videoreel.json");
    final data = await json.decode(response);
    setState(() {
      _items = data["data"]['rows'];
    });
    _controllers = _items
        .map((item) => VideoPlayerController.network(item['videoUrl']))
        .toList();
    (_controllers.map((controller) => controller.initialize()));
    setState(() {});
  }

  @override
  void initState() {
    readJson();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.initState();
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controllers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _controllers.length,
              onPageChanged: (value) {
                setState(() {
                  _currentPageIndex = value;
                  _controllers[_currentPageIndex].setLooping(true);
                  _controllers[_currentPageIndex].seekTo(Duration.zero);
                  _controllers[_currentPageIndex].play();
                });
              },
              itemBuilder: (context, index) {
                final chewieController = ChewieController(
                  videoPlayerController: _controllers[index],
                  aspectRatio: MediaQuery.of(context).size.aspectRatio,
                  showControls: false,
                  autoInitialize: true,
                  looping: true,
                  autoPlay: true,
                );
                return (chewieController != null)
                    ? Chewie(
                        controller: chewieController,
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      );
              },
            ),
    );
  }
}



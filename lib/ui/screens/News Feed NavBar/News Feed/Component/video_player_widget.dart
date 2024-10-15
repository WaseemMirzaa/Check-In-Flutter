import 'package:check_in/utils/colors.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    await _videoPlayerController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,  // Set this to false to prevent auto play
      looping: false,
      // Add these options for a more modern look (optional)
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorBuilder: (context, error) => Center(
        child: Text(
          'Error Playing Video: $error',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 0) {
          _videoPlayerController?.pause();
        }
      },
      child: _chewieController != null &&
          _chewieController!.videoPlayerController.value.isInitialized
          ? AspectRatio(
        aspectRatio: 3 / 2,
        child: Chewie(
          controller: _chewieController!,

        ),
      )
          : AspectRatio(
        aspectRatio: 3 / 2, // Adjust as needed for your video
        child: Container(color: appBlackColor,child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: appWhiteColor,),
          ],
        )),
      ),
    );
  }
}

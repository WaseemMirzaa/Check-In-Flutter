import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerFromFirebase extends StatefulWidget {
  final String videoUrl;

  VideoPlayerFromFirebase({required this.videoUrl});

  @override
  _VideoPlayerFromFirebaseState createState() => _VideoPlayerFromFirebaseState();
}

class _VideoPlayerFromFirebaseState extends State<VideoPlayerFromFirebase> {
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
      autoPlay: true,
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
    return _chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized
        ? AspectRatio(
      aspectRatio: 3 / 2, // Adjust as needed for your video
      child: Chewie(
        controller: _chewieController!,
      ),
    )
        : Center(
      child: CircularProgressIndicator(),
    );
  }
}

import 'dart:io';
import 'package:check_in/Services/user_services.dart';
import 'package:check_in/ui/screens/Messages%20NavBar/other_profile/other_profile_view.dart';
import 'package:check_in/ui/screens/profile_screen.dart';
import 'package:check_in/Services/newfeed_service.dart';
import 'package:check_in/auth_service.dart';
import 'package:check_in/controllers/News%20Feed/news_feed_controller.dart';
import 'package:check_in/model/NewsFeed%20Model/news_feed_model.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/Full%20Screen%20Image/full_screen_image.dart';
import 'package:check_in/ui/screens/News%20Feed%20NavBar/News%20Feed/Component/video_player_widget.dart';
import 'package:check_in/utils/loader.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:check_in/ui/widgets/custom_container.dart';
import 'package:check_in/utils/Constants/images.dart';
import 'package:check_in/utils/colors.dart';
import 'package:check_in/utils/gaps.dart';
import 'package:check_in/utils/styles.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:video_player/video_player.dart';

class SharePostComp extends StatefulWidget {
  NewsFeedModel? data;
  SharePostComp({super.key, this.data});

  @override
  State<SharePostComp> createState() => _SharePostCompState();
}

class _SharePostCompState extends State<SharePostComp> {
  NewsFeedController newsFeedController =
      Get.put(NewsFeedController(NewsFeedService()));

  final addCommentController = TextEditingController();

  final userServices = UserServices();
  bool? playing;

  @override
  Widget build(BuildContext context) {
    newsFeedController.commentModel.value.userId = widget.data!.userId;
    return FutureBuilder(
        future: userServices.getUserData(widget.data!.userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          }
          return CustomContainer1(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (userController.userModel.value.uid ==
                                widget.data!.userId) {
                              pushScreen(context,
                                  screen: ProfileScreen(
                                    isNavBar: false,
                                  ));
                            } else {
                              pushScreen(context,
                                  screen: OtherProfileView(
                                      uid: widget.data!.shareUID!));
                            }
                          },
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: snapshot
                                              .data!.photoUrl!.isEmptyOrNull
                                          ? NetworkImage(AppImage.userImagePath)
                                          : NetworkImage(
                                              snapshot.data!.photoUrl!),
                                      fit: BoxFit.cover))),
                        ),
                        horizontalGap(10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (userController.userModel.value.uid ==
                                  widget.data!.userId) {
                                pushScreen(context,
                                    screen: ProfileScreen(
                                      isNavBar: false,
                                    ));
                              } else {
                                pushScreen(context,
                                    screen: OtherProfileView(
                                        uid: widget.data!.userId!));
                              }
                            },
                            child: poppinsText(snapshot.data?.userName ?? '',
                                14, bold, appDarkBlue,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        horizontalGap(5),
                      ],
                    ),
                  ),
                  verticalGap(8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: poppinsText(widget.data!.description ?? "", 12,
                        medium, appDarkBlue.withOpacity(0.8),
                        maxlines: 3),
                  ),
                  verticalGap(8),
                  widget.data!.isType == 'image' &&
                          widget.data!.postUrl!.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            pushScreen(context,
                                screen: FullScreenImage(
                                  newsFeedModel: widget.data!,
                                ));
                          },
                          child: SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.data!.postUrl ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : widget.data!.isType == 'video'
                          ? newsFeedController.videoLoad.value
                              ? loaderView()
                              : playing ?? false
                                  ? VideoPlayerWidget(
                                      videoUrl: widget.data!.postUrl!)
                                  : GestureDetector(
                                      onTap: () {
                                        //initializePlayer(widget.data!.postUrl!);
                                        setState(() {
                                          //_playingIndex = widget.index;
                                          playing = true;
                                        });
                                      },
                                      child: SizedBox(
                                        height: 200,
                                        width: double.infinity,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: widget.data!.thumbnail ==
                                                      null
                                                  ? Container(
                                                      color: Colors.black,
                                                    )
                                                  : Image.network(
                                                      widget.data!.thumbnail!,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            Center(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                  size: 40,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                          : const SizedBox(),
                  verticalGap(10),
                ],
              ),
            ),
          );
        });
  }
}

class ChewieDemo extends StatefulWidget {
  ChewieDemo({super.key, required this.link});

  String link;
  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  TargetPlatform? _platform;
  late VideoPlayerController _videoPlayerController1;
  late VideoPlayerController _videoPlayerController2;
  ChewieController? _chewieController;
  int? bufferDelay;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _videoPlayerController2.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController1 =
        VideoPlayerController.networkUrl(Uri.parse(widget.link));
    _videoPlayerController2 =
        VideoPlayerController.networkUrl(Uri.parse(widget.link));
    await Future.wait([
      _videoPlayerController1.initialize(),
      _videoPlayerController2.initialize()
    ]);
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    // final subtitles = [
    //     Subtitle(
    //       index: 0,
    //       start: Duration.zero,
    //       end: const Duration(seconds: 10),
    //       text: 'Hello from subtitles',
    //     ),
    //     Subtitle(
    //       index: 0,
    //       start: const Duration(seconds: 10),
    //       end: const Duration(seconds: 20),
    //       text: 'Whats up? :)',
    //     ),
    //   ];

    final subtitles = [
      Subtitle(
        index: 0,
        start: Duration.zero,
        end: const Duration(seconds: 10),
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'Hello',
              style: TextStyle(color: Colors.red, fontSize: 22),
            ),
            TextSpan(
              text: ' from ',
              style: TextStyle(color: Colors.green, fontSize: 20),
            ),
            TextSpan(
              text: 'subtitles',
              style: TextStyle(color: Colors.blue, fontSize: 18),
            )
          ],
        ),
      ),
      Subtitle(
        index: 0,
        start: const Duration(seconds: 10),
        end: const Duration(seconds: 20),
        text: 'Whats up? :)',
        // text: const TextSpan(
        //   text: 'Whats up? :)',
        //   style: TextStyle(color: Colors.amber, fontSize: 22, fontStyle: FontStyle.italic),
        // ),
      ),
    ];

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      progressIndicatorDelay:
          bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,

      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: (context) {
              toggleVideo();
            },
            iconData: Icons.live_tv_sharp,
            title: 'Toggle Video Src',
          ),
        ];
      },
      subtitle: Subtitles(subtitles),
      subtitleBuilder: (context, dynamic subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: subtitle is InlineSpan
            ? RichText(
                text: subtitle,
              )
            : Text(
                subtitle.toString(),
                style: const TextStyle(color: Colors.black),
              ),
      ),

      hideControlsTimer: const Duration(seconds: 1),

      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
  }

  int currPlayIndex = 0;

  Future<void> toggleVideo() async {
    await _videoPlayerController1.pause();
    currPlayIndex += 1;
    if (currPlayIndex >= widget.link.length) {
      currPlayIndex = 0;
    }
    await initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: _chewieController != null &&
                      _chewieController!
                          .videoPlayerController.value.isInitialized
                  ? Chewie(
                      controller: _chewieController!,
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    ),
            ),
          ),
          TextButton(
            onPressed: () {
              _chewieController?.enterFullScreen();
            },
            child: const Text('Fullscreen'),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _videoPlayerController1.pause();
                      _videoPlayerController1.seekTo(Duration.zero);
                      _createChewieController();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text("Landscape Video"),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _videoPlayerController2.pause();
                      _videoPlayerController2.seekTo(Duration.zero);
                      _chewieController = _chewieController!.copyWith(
                        videoPlayerController: _videoPlayerController2,
                        autoPlay: true,
                        looping: true,
                        /* subtitle: Subtitles([
                            Subtitle(
                              index: 0,
                              start: Duration.zero,
                              end: const Duration(seconds: 10),
                              text: 'Hello from subtitles',
                            ),
                            Subtitle(
                              index: 0,
                              start: const Duration(seconds: 10),
                              end: const Duration(seconds: 20),
                              text: 'Whats up? :)',
                            ),
                          ]),
                          subtitleBuilder: (context, subtitle) => Container(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              subtitle,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ), */
                      );
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text("Portrait Video"),
                  ),
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _platform = TargetPlatform.android;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text("Android controls"),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _platform = TargetPlatform.iOS;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text("iOS controls"),
                  ),
                ),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _platform = TargetPlatform.windows;
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text("Desktop controls"),
                  ),
                ),
              ),
            ],
          ),
          if (Platform.isAndroid)
            ListTile(
              title: const Text("Delay"),
              subtitle: DelaySlider(
                delay:
                    _chewieController?.progressIndicatorDelay?.inMilliseconds,
                onSave: (delay) async {
                  if (delay != null) {
                    bufferDelay = delay == 0 ? null : delay;
                    await initializePlayer();
                  }
                },
              ),
            )
        ],
      ),
    );
  }
}

class DelaySlider extends StatefulWidget {
  const DelaySlider({super.key, required this.delay, required this.onSave});

  final int? delay;
  final void Function(int?) onSave;
  @override
  State<DelaySlider> createState() => _DelaySliderState();
}

class _DelaySliderState extends State<DelaySlider> {
  int? delay;
  bool saved = false;

  @override
  void initState() {
    super.initState();
    delay = widget.delay;
  }

  @override
  Widget build(BuildContext context) {
    const int max = 1000;
    return ListTile(
      title: Text(
        "Progress indicator delay ${delay != null ? "${delay.toString()} MS" : ""}",
      ),
      subtitle: Slider(
        value: delay != null ? (delay! / max) : 0,
        onChanged: (value) async {
          delay = (value * max).toInt();
          setState(() {
            saved = false;
          });
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.save),
        onPressed: saved
            ? null
            : () {
                widget.onSave(delay);
                setState(() {
                  saved = true;
                });
              },
      ),
    );
  }
}

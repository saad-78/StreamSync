// lib/features/video/presentation/widgets/platform_video_player.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../../data/models/video_model.dart';

class PlatformVideoPlayer extends StatefulWidget {
  final VideoModel video;

  const PlatformVideoPlayer({
    super.key,
    required this.video,
  });

  @override
  State<PlatformVideoPlayer> createState() => _PlatformVideoPlayerState();
}

class _PlatformVideoPlayerState extends State<PlatformVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      aspectRatio: 16 / 9,
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

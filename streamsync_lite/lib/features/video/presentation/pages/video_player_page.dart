// lib/features/video/presentation/pages/video_player_page.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../data/models/video_model.dart';
import '../widgets/platform_video_player.dart';

class VideoPlayerPage extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  bool _isFavorite = false;
  late final ApiService _apiService;
  int _lastSavedPosition = 0;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(Dio(), SecureStorage());
  }

  void _handleProgressUpdate(int positionSeconds) async {
    // Save progress every 10 seconds
    if (positionSeconds - _lastSavedPosition >= 10) {
      _lastSavedPosition = positionSeconds;
      
      final duration = widget.video.durationSeconds;
      final percent = duration > 0 ? ((positionSeconds / duration) * 100).round() : 0;
      
      try {
        await _apiService.saveProgress(
          widget.video.videoId,
          positionSeconds,
          percent,
        );
        print('✅ Progress saved: ${positionSeconds}s ($percent%)');
      } catch (e) {
        print('⚠️ Failed to save progress: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            color: _isFavorite ? Colors.red : null,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: Column(
        children: [
          // Video Player
          PlatformVideoPlayer(
             video: widget.video,   
              ),
          
          // Video Info
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.space4),
              children: [
                Text(
                  widget.video.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppTheme.space2),
                Row(
                  children: [
                    Text(
                      '${timeago.format(widget.video.publishedAt)} • ${widget.video.formattedDuration}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.space4),
                const Divider(),
                const SizedBox(height: AppTheme.space4),
                
                // Channel Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Text(
                        widget.video.channelTitle[0].toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space3),
                    Expanded(
                      child: Text(
                        widget.video.channelTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.space4),
                const Divider(),
                const SizedBox(height: AppTheme.space4),
                
                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.space2),
                Text(
                  widget.video.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavorite = !_isFavorite);
    
    try {
      if (_isFavorite) {
        await _apiService.addFavorite(widget.video.videoId);
      } else {
        await _apiService.removeFavorite(widget.video.videoId);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorite ? '✅ Added to favorites' : 'Removed from favorites'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert on error
      setState(() => _isFavorite = !_isFavorite);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

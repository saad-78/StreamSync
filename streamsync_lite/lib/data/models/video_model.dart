class VideoModel {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelId;
  final String channelTitle;
  final DateTime publishedAt;
  final int durationSeconds;

  VideoModel({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelId,
    required this.channelTitle,
    required this.publishedAt,
    required this.durationSeconds,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: json['video_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      channelId: json['channel_id'] ?? '',
      channelTitle: json['channel_title'] ?? '',
      publishedAt: DateTime.parse(json['published_at']),
      durationSeconds: json['duration_seconds'] ?? 0,
    );
  }

  String get formattedDuration {
    final duration = Duration(seconds: durationSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}

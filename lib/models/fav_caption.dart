class FavoriteCaption {
  final String userId;
  final String captionId;
  final String caption;
  final bool isSynced;

  FavoriteCaption({
    required this.userId,
    required this.captionId,
    required this.caption,
    required this.isSynced,
  });

  // Add this copyWith method
  FavoriteCaption copyWith({
    String? userId,
    String? captionId,
    String? caption,
    bool? isSynced,
    DateTime? createdAt,
  }) {
    return FavoriteCaption(
      userId: userId ?? this.userId,
      captionId: captionId ?? this.captionId,
      caption: caption ?? this.caption,
      isSynced: isSynced ?? this.isSynced,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'captionId': captionId,
      'caption': caption,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory FavoriteCaption.fromMap(Map<String, dynamic> map) {
    return FavoriteCaption(
      userId: map['userId'] as String,
      captionId: map['captionId'] as String,
      caption: map['caption'] as String,
      isSynced: (map['isSynced'] as int) == 1,
    );
  }
}
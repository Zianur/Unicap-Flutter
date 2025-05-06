
class CaptionCategory {
  final String? name;
  final String? imageUrl;
  final int? captionsCount; // Number of captions
  final List<Caption>? captions; // List of captions

  CaptionCategory({
    required this.name,
    required this.imageUrl,
    required this.captionsCount,
    required this.captions,
  });

  factory CaptionCategory.fromMap(Map<dynamic, dynamic> data) {
    // Fetch captions under the 'Captions' node
    List<Caption> captions = [];
    if (data['Captions'] != null && data['Captions'] is Map) {
      Map<dynamic, dynamic> captionsMap = data['Captions'] as Map;
      captionsMap.forEach((key, value) {
        if (value is Map) {
          captions.add(Caption.fromMap(key, value));
        }
      });
    }

    return CaptionCategory(
      name: data['name'] ?? 'No Name',
      imageUrl: data['image'] ?? 'No Image',
      captionsCount: captions.length,
      captions: captions,
    );
  }
}


class Caption {
  final String key; // The dynamic key (e.g., "09-February-202223:1741")
  final String caption; // The caption text

  Caption({required this.key, required this.caption});

  factory Caption.fromMap(String key, Map<dynamic, dynamic> data) {
    return Caption(
      key: key,
      caption: data['caption'] ?? 'No Caption',
    );
  }
}
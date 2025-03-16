import 'package:firebase_database/firebase_database.dart';

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

class CaptionCategory {
  final String name;
  final String imageUrl;
  final int captionsCount; // Number of captions
  final List<Caption> captions; // List of captions

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

Future<List<CaptionCategory>> fetchAllCategories() async {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('AllCaptions');
  List<CaptionCategory> categories = [];

  try {
    // Fetch data from the 'AllCaptions' node
    DatabaseEvent event = await databaseRef.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      // Convert the snapshot value to a Map
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      // Iterate through each category (e.g., Aesthetic, Alone, Angry)
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          // Create a CaptionCategory object and add it to the list
          categories.add(CaptionCategory.fromMap(value));
        }
      });
    }
  } catch (e) {
    print('Error fetching categories: $e');
  }

  return categories;
}

void main() async {
  List<CaptionCategory> categories = await fetchAllCategories();

  // Print the fetched categories and their captions
  categories.forEach((category) {
    print('Name: ${category.name}, Image: ${category.imageUrl}, Captions Count: ${category.captionsCount}');
    category.captions.forEach((caption) {
      print('  Caption Key: ${caption.key}, Caption: ${caption.caption}');
    });
  });
}
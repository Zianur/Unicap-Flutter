class DiaryEntry {
  String userId;
  String noteId;
  String noteName;
  String note;
  bool isSynced;

  DiaryEntry({
    required this.userId,
    required this.noteId,
    required this.note,
    required this.isSynced,
    required this.noteName
  });

  // Convert to Map (for database/JSON)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'noteId': noteId,
      'name': noteName,
      'note': note,
      'isSynced': isSynced ? 1 : 0, // Store bool as int
    };
  }

  // Create Note from Map (from database/JSON)
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      userId: map['userId'] as String,
      noteId: map['noteId'] as String,
      note: map['note'] as String,
      isSynced: (map['isSynced'] as int) == 1,// Convert int back to bool
      noteName: map['note'] as String,
    );
  }
}
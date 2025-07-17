class ChatMessage {
  final String id;
  final String sender;
  final String text;
  final DateTime timestamp;
  final String? emotion;
  final bool isEdited;

  ChatMessage({
    String? id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.emotion,
    this.isEdited = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'emotion': emotion,
      'isEdited': isEdited,
    };
  }

  // Create from Map
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      sender: map['sender'],
      text: map['text'],
      timestamp: DateTime.parse(map['timestamp']),
      emotion: map['emotion'],
      isEdited: map['isEdited'] ?? false,
    );
  }

  // Copy with method for editing
  ChatMessage copyWith({
    String? id,
    String? sender,
    String? text,
    DateTime? timestamp,
    String? emotion,
    bool? isEdited,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      emotion: emotion ?? this.emotion,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final String userId;

  ChatSession({
    String? id,
    required this.title,
    required this.messages,
    DateTime? createdAt,
    DateTime? lastUpdated,
    required this.userId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       createdAt = createdAt ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now();

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((msg) => msg.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'userId': userId,
    };
  }

  // Create from Map
  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'],
      title: map['title'],
      messages: (map['messages'] as List<dynamic>)
          .map((msgMap) => ChatMessage.fromMap(msgMap))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      userId: map['userId'],
    );
  }

  // Copy with method for updates
  ChatSession copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? userId,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      userId: userId ?? this.userId,
    );
  }

  // Generate a title from the first user message
  String generateTitle() {
    final firstUserMessage = messages.firstWhere(
      (msg) => msg.sender != 'Mustafa',
      orElse: () => ChatMessage(
        sender: 'User', 
        text: 'New Chat', 
        timestamp: DateTime.now(),
      ),
    );
    
    String title = firstUserMessage.text;
    if (title.length > 30) {
      title = '${title.substring(0, 30)}...';
    }
    return title;
  }

  // Get preview of the last message
  String getLastMessagePreview() {
    if (messages.isEmpty) return 'No messages';
    final lastMessage = messages.last;
    String preview = lastMessage.text;
    if (preview.length > 50) {
      preview = '${preview.substring(0, 50)}...';
    }
    return preview;
  }
}

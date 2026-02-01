class Message {
  final String id;
  final String text;
  final String senderId;
  final int timestamp;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
  });

  factory Message.fromMap(Map<dynamic, dynamic> map, String id) {
    return Message(
      id: id,
      text: map['text'] as String? ?? '',
      senderId: map['senderId'] as String? ?? 'anonymous',
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp,
    };
  }
}
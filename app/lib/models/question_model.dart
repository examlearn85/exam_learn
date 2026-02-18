import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final int order;
  final String? categoryId;
  final int? chapterNumber;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.order,
    this.categoryId,
    this.chapterNumber,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Question(
      id: doc.id,
      question: data['question'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      explanation: data['explanation'] ?? '',
      order: data['order'] ?? 0,
      categoryId: data['categoryId'],
      chapterNumber: data['chapterNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'order': order,
      if (categoryId != null) 'categoryId': categoryId,
      if (chapterNumber != null) 'chapterNumber': chapterNumber,
    };
  }
}


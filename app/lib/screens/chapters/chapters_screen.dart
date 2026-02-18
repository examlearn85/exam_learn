import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../quiz/quiz_screen.dart';

class ChaptersScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const ChaptersScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final currentChapter = userData?['currentChapter'] ?? 1;
    final completedChapters = List<int>.from(userData?['completedChapters'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('chapters')
            .orderBy('chapterNumber')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chapters available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final chapter = snapshot.data!.docs[index];
              final data = chapter.data() as Map<String, dynamic>;
              final chapterNumber = data['chapterNumber'] ?? (index + 1);
              final isLocked = chapterNumber > currentChapter;
              final isCompleted = completedChapters.contains(chapterNumber);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isLocked
                        ? Colors.grey
                        : isCompleted
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                    child: Text(
                      '$chapterNumber',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    data['name'] ?? 'Chapter $chapterNumber',
                    style: TextStyle(
                      color: isLocked ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(
                    chapterNumber == 1
                        ? '10 Questions • 20s Timer • ₹20 Reward'
                        : '20 Questions • 10s Timer • 15 Gold Coins',
                    style: TextStyle(
                      color: isLocked ? Colors.grey : null,
                    ),
                  ),
                  trailing: isLocked
                      ? const Icon(Icons.lock, color: Colors.grey)
                      : isCompleted
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.arrow_forward_ios),
                  onTap: isLocked
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                categoryId: categoryId,
                                chapterNumber: chapterNumber,
                                chapterName: data['name'] ?? 'Chapter $chapterNumber',
                              ),
                            ),
                          );
                        },
                ),
              );
            },
          );
        },
      ),
    );
  }
}


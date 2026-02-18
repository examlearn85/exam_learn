import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chapters/chapters_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .orderBy('order')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No categories available'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final category = snapshot.data!.docs[index];
              final data = category.data() as Map<String, dynamic>;
              
              return Card(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChaptersScreen(
                          categoryId: category.id,
                          categoryName: data['name'] ?? 'Category',
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getCategoryIcon(data['name'] ?? ''),
                        size: 50,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['name'] ?? 'Category',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toUpperCase()) {
      case '5-12TH CLASS':
        return Icons.school;
      case 'SSC':
        return Icons.work;
      case 'RRB':
        return Icons.train;
      case 'BANK':
        return Icons.account_balance;
      case 'IAS/PCS':
        return Icons.gavel;
      case 'SCIENCE':
        return Icons.science;
      case 'MATH':
        return Icons.calculate;
      case 'HISTORY':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }
}


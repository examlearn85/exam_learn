import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_config.dart';
import 'withdrawal_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final currentChapter = userData?['currentChapter'] ?? 1;
    final completedChapters = List<int>.from(userData?['completedChapters'] ?? []);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Wallet Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      size: 60,
                      color: Color(0xFFCBFE1C),
                    ),
                    const SizedBox(height: 20),
                    Consumer<WalletProvider>(
                      builder: (context, wallet, _) {
                        return Column(
                          children: [
                            Text(
                              '₹${wallet.cashBalance.toStringAsFixed(0)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Cash Balance',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.monetization_on,
                                  color: Color(0xFFCBFE1C),
                                  size: 30,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '${wallet.goldCoins}',
                                  style: Theme.of(context).textTheme.displaySmall,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Gold Coins',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Progress Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROGRESS',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Current Chapter: $currentChapter',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completed: ${completedChapters.length}/$currentChapter',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: completedChapters.length / AppConfig.totalChapters,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${((completedChapters.length / AppConfig.totalChapters) * 100).toStringAsFixed(0)}% Complete',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Withdrawal Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WITHDRAWAL',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Consumer<WalletProvider>(
                      builder: (context, wallet, _) {
                        final canWithdraw = currentChapter >=
                                AppConfig.requiredChapterForWithdrawal &&
                            wallet.goldCoins >= AppConfig.requiredCoinsForWithdrawal;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              canWithdraw
                                  ? 'You are eligible to withdraw!'
                                  : 'Requirements for withdrawal:',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            _buildRequirementItem(
                              context,
                              'Complete Chapter ${AppConfig.requiredChapterForWithdrawal}',
                              currentChapter >=
                                  AppConfig.requiredChapterForWithdrawal,
                            ),
                            _buildRequirementItem(
                              context,
                              'Have ${AppConfig.requiredCoinsForWithdrawal} Gold Coins',
                              wallet.goldCoins >=
                                  AppConfig.requiredCoinsForWithdrawal,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: canWithdraw
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const WithdrawalScreen(),
                                        ),
                                      );
                                    }
                                  : null,
                              child: const Text('REQUEST WITHDRAWAL'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Transaction History (Future implementation)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECENT ACTIVITY',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No recent transactions',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(
    BuildContext context,
    String text,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted
                ? Colors.green
                : Theme.of(context).textTheme.bodyLarge?.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isCompleted
                        ? Colors.green
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}


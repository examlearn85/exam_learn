import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../providers/quiz_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/ads_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_config.dart';
import '../reward/reward_screen.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final int chapterNumber;
  final String chapterName;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.chapterNumber,
    required this.chapterName,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadQuiz();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Provider.of<QuizProvider>(context, listen: false).resetQuiz();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive) {
      // App went to background - fail quiz
      quizProvider.pauseQuiz();
      if (quizProvider.isQuizActive) {
        _showAppSwitchDialog();
      }
    } else if (state == AppLifecycleState.resumed) {
      quizProvider.updateLastActiveTime();
    }
  }

  Future<void> _loadQuiz() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    final loaded = await quizProvider.loadQuestions(
      widget.categoryId,
      widget.chapterNumber,
    );

    if (loaded && mounted) {
      quizProvider.startQuiz(widget.chapterNumber);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load questions')),
      );
      Navigator.pop(context);
    }
  }

  void _showAppSwitchDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Failed'),
        content: const Text('App switch detected! Quiz has been failed.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Prevent back button during quiz
          final quizProvider = Provider.of<QuizProvider>(context, listen: false);
          if (quizProvider.isQuizActive) {
            _showExitDialog();
          } else {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chapterName),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<QuizProvider>(
          builder: (context, quizProvider, _) {
            if (quizProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (quizProvider.isQuizComplete) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleQuizComplete(quizProvider);
              });
              return const Center(child: CircularProgressIndicator());
            }

            if (quizProvider.hasSwitchedApp) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showAppSwitchDialog();
              });
              return const Center(child: Text('Quiz Failed'));
            }

            final question = quizProvider.currentQuestion;
            if (question == null) {
              return const Center(child: Text('No question available'));
            }

            return Column(
              children: [
                // Progress and Timer
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${quizProvider.currentQuestionIndex + 1}/${quizProvider.totalQuestions}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: quizProvider.timeRemaining <= 5
                                  ? Colors.red
                                  : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${quizProvider.timeRemaining}s',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: (quizProvider.currentQuestionIndex + 1) /
                            quizProvider.totalQuestions,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Question
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              question.question,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Options
                        ...question.options.map((option) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                quizProvider.answerQuestion(option);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                                alignment: Alignment.centerLeft,
                              ),
                              child: Text(option),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQuizComplete(QuizProvider quizProvider) async {
    final score = quizProvider.score;
    final totalQuestions = quizProvider.totalQuestions;
    final isPassed = score >= (totalQuestions * 0.6); // 60% to pass

    if (isPassed) {
      // Add reward
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      await walletProvider.addReward(widget.chapterNumber, isPassed: true);

      // Update user progress
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userData = authProvider.userData;
      final completedChapters = List<int>.from(userData?['completedChapters'] ?? []);
      
      if (!completedChapters.contains(widget.chapterNumber)) {
        completedChapters.add(widget.chapterNumber);
      }

      int nextChapter = widget.chapterNumber + 1;
      if (nextChapter > (userData?['currentChapter'] ?? 1)) {
        await authProvider.updateUserData({
          'currentChapter': nextChapter,
          'completedChapters': completedChapters,
        });
      } else {
        await authProvider.updateUserData({
          'completedChapters': completedChapters,
        });
      }

      // Show interstitial ad every 2 chapters
      if (widget.chapterNumber % AppConfig.interstitialAdFrequency == 0) {
        final adsProvider = Provider.of<AdsProvider>(context, listen: false);
        await adsProvider.showInterstitialAd();
      }

      // Navigate to reward screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RewardScreen(
              chapterNumber: widget.chapterNumber,
              score: score,
              totalQuestions: totalQuestions,
              reward: widget.chapterNumber == 1
                  ? '₹${AppConfig.chapter1RewardCash}'
                  : '${AppConfig.chapter11to50RewardCoins} Gold Coins',
            ),
          ),
        );
      }
    } else {
      // Failed - show retry option with ad
      if (mounted) {
        _showRetryDialog();
      }
    }
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Failed'),
        content: const Text(
          'You need to score at least 60% to pass. Watch an ad to retry?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final adsProvider = Provider.of<AdsProvider>(context, listen: false);
              final watched = await adsProvider.showRewardedAd();
              
              if (watched && mounted) {
                // Reload quiz
                _loadQuiz();
              }
            },
            child: const Text('Watch Ad & Retry'),
          ),
        ],
      ),
    );
  }
}


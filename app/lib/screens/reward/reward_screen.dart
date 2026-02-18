import 'package:flutter/material.dart';
import 'dart:math';
import '../../utils/app_config.dart';

class RewardScreen extends StatefulWidget {
  final int chapterNumber;
  final int score;
  final int totalQuestions;
  final String reward;

  const RewardScreen({
    super.key,
    required this.chapterNumber,
    required this.score,
    required this.totalQuestions,
    required this.reward,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _showCoins = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showCoins = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinning Wheel Animation
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.celebration,
                          size: 100,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              // Score
              Text(
                'CONGRATULATIONS!',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'You scored ${widget.score}/${widget.totalQuestions}',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Reward
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 60,
                      color: Color(0xFFCBFE1C),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'YOU EARNED',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.reward,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              // Flying Coins Animation
              if (_showCoins)
                ...List.generate(10, (index) {
                  return Positioned(
                    left: Random().nextDouble() * 300,
                    top: Random().nextDouble() * 400,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 1000 + (index * 100)),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: 1 - value,
                          child: Transform.translate(
                            offset: Offset(
                              (Random().nextDouble() - 0.5) * 200,
                              -value * 300,
                            ),
                            child: const Icon(
                              Icons.monetization_on,
                              color: Color(0xFFCBFE1C),
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              const SizedBox(height: 60),
              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                child: const Text('CONTINUE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


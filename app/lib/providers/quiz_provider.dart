import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../models/question_model.dart';
import '../utils/app_config.dart';

class QuizProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeRemaining = 0;
  Timer? _timer;
  bool _isQuizActive = false;
  bool _isQuizPaused = false;
  DateTime? _quizStartTime;
  DateTime? _lastActiveTime;
  bool _hasSwitchedApp = false;
  
  // Getters
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  int get timeRemaining => _timeRemaining;
  bool get isQuizActive => _isQuizActive;
  bool get isQuizPaused => _isQuizPaused;
  Question? get currentQuestion => 
      _currentQuestionIndex < _questions.length 
          ? _questions[_currentQuestionIndex] 
          : null;
  int get totalQuestions => _questions.length;
  bool get isQuizComplete => _currentQuestionIndex >= _questions.length;
  bool get hasSwitchedApp => _hasSwitchedApp;

  // Load questions for a chapter
  Future<bool> loadQuestions(String categoryId, int chapterNumber) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final querySnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('chapters')
          .doc('chapter_$chapterNumber')
          .collection('questions')
          .orderBy('order')
          .get();
      
      _questions = querySnapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();
      
      _isLoading = false;
      notifyListeners();
      return _questions.isNotEmpty;
    } catch (e) {
      debugPrint('Error loading questions: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Start quiz
  void startQuiz(int chapterNumber) {
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizActive = true;
    _isQuizPaused = false;
    _hasSwitchedApp = false;
    _quizStartTime = DateTime.now();
    _lastActiveTime = DateTime.now();
    
    // Set timer based on chapter
    if (chapterNumber == 1) {
      _timeRemaining = AppConfig.chapter1TimerSeconds;
    } else {
      _timeRemaining = AppConfig.chapter11to50TimerSeconds;
    }
    
    _startTimer();
    notifyListeners();
  }

  // Start timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isQuizPaused || !_isQuizActive) return;
      
      // Check if app was switched
      _checkAppSwitch();
      
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        // Time's up - auto fail
        _handleTimeUp();
      }
    });
  }

  // Check if app was switched (cheat detection)
  void _checkAppSwitch() {
    final now = DateTime.now();
    if (_lastActiveTime != null) {
      final diff = now.difference(_lastActiveTime!);
      // If more than 2 seconds gap, user might have switched apps
      if (diff.inSeconds > 2) {
        _hasSwitchedApp = true;
        _failQuiz('App switch detected!');
      }
    }
    _lastActiveTime = now;
  }

  // Update last active time (call from app lifecycle)
  void updateLastActiveTime() {
    _lastActiveTime = DateTime.now();
  }

  // Answer question
  void answerQuestion(String selectedAnswer) {
    if (!_isQuizActive || _isQuizPaused) return;
    
    final question = currentQuestion;
    if (question == null) return;
    
    if (selectedAnswer == question.correctAnswer) {
      _score++;
    }
    
    _moveToNextQuestion();
  }

  // Move to next question
  void _moveToNextQuestion() {
    _currentQuestionIndex++;
    
    if (isQuizComplete) {
      _completeQuiz();
    } else {
      // Reset timer for next question
      final chapterNumber = _getCurrentChapterNumber();
      if (chapterNumber == 1) {
        _timeRemaining = AppConfig.chapter1TimerSeconds;
      } else {
        _timeRemaining = AppConfig.chapter11to50TimerSeconds;
      }
    }
    
    notifyListeners();
  }

  // Handle time up
  void _handleTimeUp() {
    _failQuiz('Time\'s up!');
  }

  // Fail quiz
  void _failQuiz(String reason) {
    _timer?.cancel();
    _isQuizActive = false;
    notifyListeners();
  }

  // Complete quiz
  void _completeQuiz() {
    _timer?.cancel();
    _isQuizActive = false;
    notifyListeners();
  }

  // Pause quiz (when app goes to background)
  void pauseQuiz() {
    if (!_isQuizActive) return;
    _isQuizPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  // Resume quiz
  void resumeQuiz() {
    if (!_isQuizActive || !_isQuizPaused) return;
    _isQuizPaused = false;
    _startTimer();
    notifyListeners();
  }

  // Reset quiz
  void resetQuiz() {
    _timer?.cancel();
    _questions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _timeRemaining = 0;
    _isQuizActive = false;
    _isQuizPaused = false;
    _hasSwitchedApp = false;
    _quizStartTime = null;
    _lastActiveTime = null;
    notifyListeners();
  }

  int _getCurrentChapterNumber() {
    // This should be passed from the screen
    // For now, return 1 as default
    return 1;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}


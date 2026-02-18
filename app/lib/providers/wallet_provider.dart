import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import '../utils/app_config.dart';

class WalletProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  int _goldCoins = 0;
  double _cashBalance = 0;
  String? _userId;
  bool _isLoading = false;

  int get goldCoins => _goldCoins;
  double get cashBalance => _cashBalance;
  bool get isLoading => _isLoading;
  bool get canWithdraw => 
      _goldCoins >= AppConfig.requiredCoinsForWithdrawal;

  // Initialize wallet for user
  Future<void> initializeWallet(String userId) async {
    _userId = userId;
    await _loadWalletData();
  }

  // Load wallet data
  Future<void> _loadWalletData() async {
    if (_userId == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        _goldCoins = data?['goldCoins'] ?? 0;
        _cashBalance = (data?['cashBalance'] ?? 0).toDouble();
      }
    } catch (e) {
      debugPrint('Error loading wallet: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add reward after completing chapter
  Future<bool> addReward(int chapterNumber, {bool isPassed = true}) async {
    if (_userId == null || !isPassed) return false;
    
    try {
      if (chapterNumber == 1) {
        // Chapter 1: ₹20 cash
        _cashBalance += AppConfig.chapter1RewardCash;
        await _updateWallet({
          'cashBalance': FieldValue.increment(AppConfig.chapter1RewardCash),
          'totalEarnings': FieldValue.increment(AppConfig.chapter1RewardCash),
        });
      } else if (chapterNumber >= 11 && chapterNumber <= 50) {
        // Chapter 11-50: 15 Gold Coins
        _goldCoins += AppConfig.chapter11to50RewardCoins;
        await _updateWallet({
          'goldCoins': FieldValue.increment(AppConfig.chapter11to50RewardCoins),
        });
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding reward: $e');
      return false;
    }
  }

  // Update wallet in Firestore
  Future<void> _updateWallet(Map<String, dynamic> updates) async {
    if (_userId == null) return;
    
    await _firestore
        .collection('users')
        .doc(_userId)
        .update(updates);
  }

  // Request withdrawal
  Future<bool> requestWithdrawal({
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required String bankName,
  }) async {
    if (_userId == null) return false;
    
    // Check withdrawal eligibility
    if (!_canRequestWithdrawal()) {
      return false;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      // Create withdrawal request
      final withdrawalData = {
        'userId': _userId,
        'amount': _goldCoins,
        'status': 'pending',
        'accountNumber': _encryptData(accountNumber),
        'ifscCode': _encryptData(ifscCode),
        'accountHolderName': accountHolderName,
        'bankName': bankName,
        'requestedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore
          .collection('withdrawals')
          .add(withdrawalData);
      
      // Deduct coins from wallet
      _goldCoins = 0;
      await _updateWallet({
        'goldCoins': 0,
        'lastWithdrawalRequest': FieldValue.serverTimestamp(),
      });
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error requesting withdrawal: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user can request withdrawal
  bool _canRequestWithdrawal() {
    // User must have completed Chapter 50
    // This should be checked from user's progress
    // For now, just check coins
    return _goldCoins >= AppConfig.requiredCoinsForWithdrawal;
  }

  // Encrypt sensitive data
  String _encryptData(String data) {
    final key = encrypt.Key.fromBase64(AppConfig.walletEncryptionKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(data, iv: iv);
    return encrypted.base64;
  }

  // Refresh wallet data
  Future<void> refreshWallet() async {
    await _loadWalletData();
  }
}


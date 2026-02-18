import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userData = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_user!.uid)
          .get();
      
      if (doc.exists) {
        _userData = doc.data();
      } else {
        // Create user document if doesn't exist
        await _createUserDocument();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _createUserDocument() async {
    if (_user == null) return;
    
    _userData = {
      'uid': _user!.uid,
      'email': _user!.email,
      'name': _user!.displayName ?? '',
      'phone': _user!.phoneNumber ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'currentChapter': 1,
      'completedChapters': [],
      'goldCoins': 0,
      'cashBalance': 0,
      'totalEarnings': 0,
      'isVerified': false,
    };
    
    await _firestore
        .collection('users')
        .doc(_user!.uid)
        .set(_userData!);
  }

  Future<bool> signInWithPhone(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: $e');
        },
        codeSent: (String verificationId, int? resendToken) {
          // Handle code sent
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await credential.user?.updateDisplayName(name);
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _userData = null;
    notifyListeners();
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_user == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_user!.uid)
          .update(data);
      
      _userData?.addAll(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }
}


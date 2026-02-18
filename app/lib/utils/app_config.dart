class AppConfig {
  // AdMob IDs - Replace with your actual IDs
  static const String admobAppId = 'ca-app-pub-3940256099942544~3347511713'; // Test ID
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  static const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String categoriesCollection = 'categories';
  static const String chaptersCollection = 'chapters';
  static const String questionsCollection = 'questions';
  static const String withdrawalsCollection = 'withdrawals';
  static const String appConfigCollection = 'app_config';
  
  // Quiz Configuration
  static const int totalChapters = 50;
  static const int chapter1Questions = 10;
  static const int chapter1TimerSeconds = 20;
  static const int chapter11to50Questions = 20;
  static const int chapter11to50TimerSeconds = 10;
  static const int chapter1RewardCash = 20; // ₹20
  static const int chapter11to50RewardCoins = 15; // 15 Gold Coins
  
  // Withdrawal Rules
  static const int requiredChapterForWithdrawal = 50;
  static const int requiredCoinsForWithdrawal = 500;
  
  // Interstitial Ad Frequency
  static const int interstitialAdFrequency = 2; // Every 2 chapters
  
  // APK Update Check URL
  static const String updateCheckUrl = 'https://your-server.com/api/check-update';
  
  // Encryption Key (Store securely in production)
  static const String walletEncryptionKey = 'your-32-character-encryption-key!!';
}


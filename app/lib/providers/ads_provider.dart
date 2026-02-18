import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/app_config.dart';

class AdsProvider with ChangeNotifier {
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;
  bool _isRewardedAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  int _chapterCount = 0;

  bool get isRewardedAdLoaded => _isRewardedAdLoaded;
  bool get isInterstitialAdLoaded => _isInterstitialAdLoaded;

  // Load Rewarded Ad (for retry)
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AppConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          _isRewardedAdLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  // Show Rewarded Ad (for retry)
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null || !_isRewardedAdLoaded) {
      loadRewardedAd();
      return false;
    }

    bool adWatched = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd(); // Load next ad
        notifyListeners();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedAdLoaded = false;
        loadRewardedAd();
        notifyListeners();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        adWatched = true;
      },
    );

    return adWatched;
  }

  // Load Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AppConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          _isInterstitialAdLoaded = false;
          notifyListeners();
        },
      ),
    );
  }

  // Show Interstitial Ad (every 2 chapters)
  Future<void> showInterstitialAd() async {
    _chapterCount++;
    
    // Show ad every 2 chapters
    if (_chapterCount % AppConfig.interstitialAdFrequency == 0) {
      if (_interstitialAd == null || !_isInterstitialAdLoaded) {
        loadInterstitialAd();
        return;
      }

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          loadInterstitialAd(); // Load next ad
          notifyListeners();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdLoaded = false;
          loadInterstitialAd();
          notifyListeners();
        },
      );

      await _interstitialAd!.show();
    }
  }

  // Initialize ads
  void initializeAds() {
    loadRewardedAd();
    loadInterstitialAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}


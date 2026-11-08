import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'preferences_service.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static String get interstitialAdUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-2913289160482051/6003166560';

  static String get rewardedAdUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-2913289160482051/5837415534';

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialAdReady = false;
  bool _isInterstitialAdLoading = false;
  bool _isInterstitialAdShowing = false;
  bool _isRewardedAdLoading = false;
  bool _isRewardedAdShowing = false;
  VoidCallback? _pendingRewardedCallback;
  int _remainingAdsToUnlock = 1;
  Function? _onAdDismissed;

  int get remainingAdsToUnlock => _remainingAdsToUnlock;

  void loadInterstitialAd() {
    if (_isInterstitialAdLoading ||
        _isInterstitialAdReady ||
        _isInterstitialAdShowing) {
      return;
    }

    _isInterstitialAdLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isInterstitialAdLoading = false;
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          _setupAdCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoading = false;
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _setupAdCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isInterstitialAdShowing = false;
        _interstitialAd = null;
        ad.dispose();
        _remainingAdsToUnlock--;
        if (_remainingAdsToUnlock <= 0) {
          _remainingAdsToUnlock = 1; // Reset for next level
        }
        _isInterstitialAdReady = false;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isInterstitialAdShowing = false;
        _interstitialAd = null;
        ad.dispose();
        _isInterstitialAdReady = false;
        loadInterstitialAd();
      },
    );
  }

  void showInterstitialAd() {
    if (!_isInterstitialAdReady ||
        _isInterstitialAdShowing ||
        _interstitialAd == null) {
      return;
    }

    final ad = _interstitialAd!;
    _interstitialAd = null;
    _isInterstitialAdReady = false;
    _isInterstitialAdShowing = true;
    _setupAdCallbacks(ad);
    ad.show();
  }

  Future<void> showAdForUnlock(String levelId, Function onUnlocked) async {
    if (!_isInterstitialAdReady || _interstitialAd == null) {
      loadInterstitialAd();
      return;
    }

    _onAdDismissed = () async {
      await PreferencesService.unlockLevel(levelId);
      onUnlocked();
    };

    _interstitialAd!.show();
  }

  bool get canUnlockWithAds => _remainingAdsToUnlock > 0;

  void loadRewardedAd() {
    if (_isRewardedAdLoading || _rewardedAd != null || _isRewardedAdShowing) {
      return;
    }

    _isRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _isRewardedAdLoading = false;
          _rewardedAd = ad;
          _setRewardedAdCallbacks(ad);
          final pendingCallback = _pendingRewardedCallback;
          _pendingRewardedCallback = null;
          if (pendingCallback != null) {
            showRewardedAd(pendingCallback);
          }
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isRewardedAdLoading = false;
          _pendingRewardedCallback = null;
          debugPrint('Ödüllü reklam yüklenemedi: $error');
        },
      ),
    );
  }

  void _setRewardedAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        _isRewardedAdShowing = false;
        _rewardedAd = null;
        ad.dispose();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('Ödüllü reklam gösterilemedi: $error');
        _isRewardedAdShowing = false;
        _rewardedAd = null;
        ad.dispose();
        loadRewardedAd();
      },
    );
  }

  void showRewardedAd(VoidCallback onRewarded) {
    if (_isRewardedAdShowing) return;

    if (_rewardedAd == null) {
      debugPrint('Ödüllü reklam henüz hazır değil.');
      if (_pendingRewardedCallback != null) return;
      _pendingRewardedCallback = onRewarded;
      loadRewardedAd();
      return;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;
    _isRewardedAdShowing = true;
    var rewardGranted = false;
    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        if (rewardGranted) return;
        rewardGranted = true;
        _remainingAdsToUnlock = 0;
        onRewarded();
      },
    );
  }

  void showTestAd(int currentQuestionIndex, int totalQuestions) {
    if (currentQuestionIndex == 0) {
      showInterstitialAd();
      return;
    }

    if (currentQuestionIndex == (totalQuestions ~/ 2)) {
      showInterstitialAd();
      return;
    }

    if (currentQuestionIndex == totalQuestions - 1) {
      showInterstitialAd();
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _remainingAdsToUnlock = 1;
    _isInterstitialAdReady = false;
    _isInterstitialAdLoading = false;
    _isInterstitialAdShowing = false;
    _isRewardedAdLoading = false;
    _isRewardedAdShowing = false;
    _pendingRewardedCallback = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _onAdDismissed = null;
  }
}

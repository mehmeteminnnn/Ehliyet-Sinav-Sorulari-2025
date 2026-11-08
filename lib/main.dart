import 'package:ehliyet/data/test4.dart';
import 'package:ehliyet/data/test7.dart';
import 'package:ehliyet/data/test8.dart';
import 'package:ehliyet/data/test9.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'models/question.dart';
import 'data/test1.dart';
import 'services/ad_service.dart';
import 'services/preferences_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/splash_screen.dart';
import 'models/test.dart';
import 'data/test2.dart';
import 'data/test3.dart';
import 'data/test4.dart';
import 'data/test5.dart';
import 'data/test6.dart';
import 'data/test7.dart';
import 'data/test8.dart';
import 'data/test9.dart';
import 'data/test10.dart';

const _brandPurple = Color(0xFF6D4AFF);
const _brandDeepPurple = Color(0xFF4E35B1);
const _pageBackground = Color(0xFFF5F6FB);
const _ink = Color(0xFF202038);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  final isFirstTime = await PreferencesService.isFirstTimeOpen();

  runApp(MyApp(isFirstTime: isFirstTime));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;

  const MyApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ehliyet Sınavı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandPurple,
          primary: _brandPurple,
          surface: _pageBackground,
        ),
        scaffoldBackgroundColor: _pageBackground,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) =>
            isFirstTime ? const WelcomeScreen() : const TestListScreen(),
        '/tests': (context) => const TestListScreen(),
      },
    );
  }
}

class TestListScreen extends StatefulWidget {
  const TestListScreen({super.key});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  final List<Test> tests = [
    Test1Data.getTest(),
    Test2Data.getTest(),
    Test3Data.getTest(),
    Test4Data.getTest(),
    Test5Data.getTest(),
    Test6Data.getTest(),
    Test7Data.getTest(),
    Test8Data.getTest(),
    Test9Data.getTest(),
    Test10Data.getTest()
  ];

  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _adService.loadInterstitialAd();
    _adService.loadRewardedAd();
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  void _handleLevelUnlock(int testIndex) {
    final test = tests[testIndex];
    if (testIndex > 0) {
      final previousTest = tests[testIndex - 1];
      final bool canUnlockWithPreviousTest =
          previousTest.isCompleted && (previousTest.score ?? 0) >= 35;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Seviye Kilitli'),
          content: Text(canUnlockWithPreviousTest
              ? 'Tebrikler! Önceki testi başarıyla tamamladınız. Bu seviye açıldı.'
              : 'Bu seviyeyi açmak için önceki testten en az 35 doğru yapmanız veya reklam izlemeniz gerekiyor.'),
          actions: [
            if (!canUnlockWithPreviousTest)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _adService.showRewardedAd(() {
                    setState(() {
                      test.isLocked = false;
                    });
                  });
                },
                child: const Text('Reklam İzle'),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (canUnlockWithPreviousTest) {
                  setState(() {
                    test.isLocked = false;
                  });
                }
              },
              child: Text(canUnlockWithPreviousTest ? 'Tamam' : 'İptal'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = tests.where((test) => test.isCompleted).length;
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 18, 18, 25),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_brandPurple, _brandDeepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.directions_car_rounded,
                            color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ehliyet Sınavı',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Bilgi',
                        icon: const Icon(Icons.info_outline_rounded,
                            color: Colors.white),
                        onPressed: () async {
                          await PreferencesService.resetFirstTimeOpen();
                          if (!mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WelcomeScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Hazır mısın?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Bilgini tazele, sınava bir adım daha yaklaş.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.82),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: Color(0xFFFFD66B), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '$completedCount / ${tests.length} deneme tamamlandı',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${(completedCount / tests.length * 100).round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Denemeler',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE5FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${tests.length} test',
                      style: const TextStyle(
                        color: _brandDeepPurple,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                itemCount: tests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 11),
                itemBuilder: (context, index) {
                  final test = tests[index];
                  final isLocked = test.isLocked;
                  final isCompleted = test.isCompleted;
                  final status = isLocked
                      ? 'Kilitli'
                      : isCompleted
                          ? 'Tamamlandı'
                          : test.score != null
                              ? 'Devam ediyor'
                              : 'Başlanmadı';
                  final statusColor = isLocked
                      ? const Color(0xFF9A93AA)
                      : isCompleted
                          ? const Color(0xFF1C9A72)
                          : const Color(0xFF786F91);

                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: isLocked
                          ? () => _handleLevelUnlock(index)
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TestScreen(
                                    test: test,
                                    tests: tests,
                                  ),
                                ),
                              ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFFD5F1E6)
                                : const Color(0xFFECEAF3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF40336C).withOpacity(0.035),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isLocked
                                    ? const Color(0xFFF0EFF4)
                                    : const Color(0xFFEDE8FF),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                isLocked
                                    ? Icons.lock_outline_rounded
                                    : isCompleted
                                        ? Icons.check_rounded
                                        : Icons.description_outlined,
                                color: isLocked
                                    ? const Color(0xFFAAA5B5)
                                    : _brandPurple,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Test ${test.testNumber}',
                                    style: const TextStyle(
                                      color: _ink,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isLocked)
                              TextButton(
                                onPressed: () => _handleLevelUnlock(index),
                                style: TextButton.styleFrom(
                                  foregroundColor: _brandPurple,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                ),
                                child: const Text('Kilidi aç'),
                              )
                            else
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 17, color: Color(0xFFAAA5B5)),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestScreen extends StatefulWidget {
  final Test test;
  final List<Test> tests;

  const TestScreen({
    super.key,
    required this.test,
    required this.tests,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, String> _userAnswers = {};
  bool _showResults = false;
  final AdService _adService = AdService();

  @override
  void initState() {
    super.initState();
    _adService.loadInterstitialAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _adService.showInterstitialAd();
    });
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _buildResultScreen();
    }

    final question = widget.test.questions[_currentQuestionIndex];
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        title: Text(
          'Test ${widget.test.testNumber}',
          style: const TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAE5FF),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              '${_currentQuestionIndex + 1} / ${widget.test.questions.length}',
              style: const TextStyle(
                color: _brandDeepPurple,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'SINAV İLERLEMESİ',
                          style: TextStyle(
                            color: Color(0xFF77738A),
                            fontSize: 11,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${((_currentQuestionIndex + 1) / widget.test.questions.length * 100).round()}%',
                        style: const TextStyle(
                          color: _brandDeepPurple,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: (_currentQuestionIndex + 1) /
                          widget.test.questions.length,
                      backgroundColor: const Color(0xFFE6E3EF),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(_brandPurple),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFECEAF3)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF40336C).withOpacity(0.045),
                            blurRadius: 20,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEAE5FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'SORU ${_currentQuestionIndex + 1}',
                                  style: const TextStyle(
                                    color: _brandDeepPurple,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.lightbulb_outline_rounded,
                                  color: Color(0xFFB9A8F5), size: 20),
                            ],
                          ),
                          if (question.imageUrl != null) ...[
                            const SizedBox(height: 17),
                            Container(
                              height: 220,
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F6FA),
                                borderRadius: BorderRadius.circular(18),
                                border:
                                    Border.all(color: const Color(0xFFECEAF3)),
                              ),
                              child: Image.asset(
                                question.imageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.image_not_supported_outlined,
                                          color: Color(0xFF9A93AA), size: 32),
                                      SizedBox(height: 8),
                                      Text('Görsel görüntülenemedi'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Text(
                            question.questionText,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.42,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Cevabını seç',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ...List.generate(question.options.length, (index) {
                      final letter = String.fromCharCode(65 + index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(17),
                            onTap: () => _submitAnswer(letter),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 66),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(17),
                                border:
                                    Border.all(color: const Color(0xFFE7E4EF)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0EDFF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      letter,
                                      style: const TextStyle(
                                        color: _brandDeepPurple,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Text(
                                      question.options[index],
                                      style: const TextStyle(
                                        color: _ink,
                                        fontSize: 15,
                                        height: 1.35,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: Color(0xFFB1AABC)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Bir seçenek işaretleyerek devam et',
                        style: TextStyle(
                          color: Color(0xFF8D879C),
                          fontSize: 12,
                        ),
                      ),
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

  Widget _buildResultScreen() {
    final correctAnswers = _calculateResults();
    final totalQuestions = widget.test.questions.length;
    final accuracy = (correctAnswers / totalQuestions * 100).round();
    final incorrect = 100 - accuracy;
    final hasPassedTest = correctAnswers >= 35;

    return Scaffold(
      backgroundColor: _brandPurple,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (hasPassedTest)
                Lottie.network(
                  'https://assets9.lottiefiles.com/packages/lf20_touohxv0.json',
                  height: 200,
                  repeat: true,
                ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Color(0xFF8B5CF6),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '+${correctAnswers} puan kazandınız',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$totalQuestions sorudan ${correctAnswers} tanesini doğru yanıtladınız',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'İstatistikler',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 100,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: CircularProgressIndicator(
                                          value:
                                              correctAnswers / totalQuestions,
                                          backgroundColor:
                                              Colors.red.withOpacity(0.2),
                                          color: Colors.blue,
                                          strokeWidth: 8,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '$totalQuestions\nSoru',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '%$accuracy Doğru',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '%$incorrect Yanlış',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.red.withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (!hasPassedTest) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Testi geçmek için en az 35 doğru yapmanız gerekmektedir. Lütfen testi tekrar çözün.',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ExpansionTile(
                      collapsedIconColor: Colors.white,
                      iconColor: Colors.white,
                      title: const Text(
                        'Cevapları Göster',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      children: [
                        Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.test.questions.length,
                            itemBuilder: (context, index) {
                              final question = widget.test.questions[index];
                              final userAnswer = _userAnswers[index] ?? '-';
                              final isCorrect =
                                  userAnswer == question.correctAnswer;

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ExpansionTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        isCorrect ? Colors.green : Colors.red,
                                    child: Text(
                                      '${index + 1}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  title: Wrap(
                                    spacing: 8,
                                    children: [
                                      Text(
                                        'Cevabınız: $userAnswer',
                                        style: TextStyle(
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (!isCorrect)
                                        Text(
                                          '(Doğru: ${question.correctAnswer})',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (question.imageUrl != null) ...[
                                            Image.asset(
                                              question.imageUrl!,
                                              height: 120,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          Text(
                                            question.questionText,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...question.options
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final optionIndex = entry.key;
                                            final option = entry.value;
                                            final optionLetter =
                                                String.fromCharCode(
                                                    65 + optionIndex);
                                            final isCorrectOption =
                                                optionLetter ==
                                                    question.correctAnswer;
                                            final isSelectedOption =
                                                optionLetter == userAnswer;

                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 4),
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: isCorrectOption
                                                    ? Colors.green
                                                        .withOpacity(0.1)
                                                    : isSelectedOption &&
                                                            !isCorrectOption
                                                        ? Colors.red
                                                            .withOpacity(0.1)
                                                        : Colors.grey
                                                            .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 30,
                                                    child: Text(
                                                      '$optionLetter) ',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isCorrectOption
                                                            ? Colors.green
                                                            : isSelectedOption &&
                                                                    !isCorrectOption
                                                                ? Colors.red
                                                                : Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      option,
                                                      style: TextStyle(
                                                        color: isCorrectOption
                                                            ? Colors.green
                                                            : isSelectedOption &&
                                                                    !isCorrectOption
                                                                ? Colors.red
                                                                : Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isCorrectOption)
                                                    const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 20)
                                                  else if (isSelectedOption &&
                                                      !isCorrectOption)
                                                    const Icon(Icons.cancel,
                                                        color: Colors.red,
                                                        size: 20),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _brandDeepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              _currentQuestionIndex = 0;
                              _userAnswers.clear();
                              _showResults = false;
                            });
                          },
                          child: const Text('Testi Tekrar Çöz'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.8)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            if (hasPassedTest) {
                              if (widget.test.testNumber <
                                  widget.tests.length) {
                                widget.tests[widget.test.testNumber].isLocked =
                                    false;
                              }
                              widget.test.isCompleted = true;
                            }
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          },
                          child: const Text('Ana Menüye Dön'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitAnswer(String answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
      if (_currentQuestionIndex < widget.test.questions.length - 1) {
        _currentQuestionIndex++;

        // Reklam gösterimi için kontrol
        _adService.showTestAd(
            _currentQuestionIndex, widget.test.questions.length);
      } else {
        _showResults = true;
      }
    });
  }

  int _calculateResults() {
    int correctAnswers = 0;
    for (int i = 0; i < widget.test.questions.length; i++) {
      if (_userAnswers[i] == widget.test.questions[i].correctAnswer) {
        correctAnswers++;
      }
    }
    return correctAnswers;
  }
}

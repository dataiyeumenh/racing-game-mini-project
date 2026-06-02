import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'login_screen.dart';
import '../core/constants.dart';
import '../services/audio_service.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _random = Random();
  final _audio = AudioService();

  // Animated cows running across the screen
  final List<_CowRunner> _runners = [];

  Timer? _animTimer;
  Timer? _spawnTimer;

  // Title pulse animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  bool _showGuide = false;

  static const _cowAssets = [
    'assets/images/cow_brown_run_frame_',
    'assets/images/cow_milk_run_frame_',
    'assets/images/cow_red_run_frame_',
  ];

  @override
  void initState() {
    super.initState();
    _audio.playBgm();

    // Pulse animation for title
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Spawn initial cows
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 1200), _spawnCow);
    }

    // Periodically spawn more cows
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (_runners.length < 5) _spawnCow();
    });

    // Animate frames & positions
    _animTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      if (!mounted) return;
      setState(() {
        for (final r in _runners) {
          r.x += r.speed;
          r.frame = (r.frame + 1) % 6;
        }
        _runners.removeWhere((r) => r.x > 1.15);
      });
    });
  }

  void _spawnCow() {
    if (!mounted) return;
    setState(() {
      _runners.add(
        _CowRunner(
          assetPrefix: _cowAssets[_random.nextInt(_cowAssets.length)],
          x: -0.2,
          y: 0.35 + _random.nextDouble() * 0.35,
          speed: 0.008 + _random.nextDouble() * 0.008,
          size: 72 + _random.nextDouble() * 32,
          frame: _random.nextInt(6),
        ),
      );
    });
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    _spawnTimer?.cancel();
    _pulseController.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A1F0A),
                  Color(0xFF1A3A1A),
                  Color(0xFF0F2D0F),
                ],
              ),
            ),
          ),

          // ── Grass stripe at bottom ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.18,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E5C1E), Color(0xFF145214)],
                ),
              ),
            ),
          ),

          // ── Track strip ──
          Positioned(
            bottom: size.height * 0.12,
            left: 0,
            right: 0,
            child: Container(
              height: size.height * 0.22,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF5C4033),
                    Color(0xFF3E2723),
                    Color(0xFF5C4033),
                  ],
                ),
              ),
            ),
          ),

          // ── Fence dots (decorative) ──
          Positioned(
            bottom: size.height * 0.33,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                12,
                (i) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(60),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // ── Animated cows ──
          ...(_runners.map(
            (r) => Positioned(
              left: r.x * size.width,
              top: r.y * size.height,
              child: Image.asset(
                '${r.assetPrefix}${r.frame + 1}.png',
                width: r.size,
                height: r.size,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          )),

          // ── Stars / sparkles ──
          ...List.generate(18, (i) {
            final rx = (i * 137.5) % 1.0;
            final ry = (i * 97.3) % 0.5;
            final rs = 1.5 + (i % 3) * 1.0;
            return Positioned(
              left: rx * size.width,
              top: ry * size.height,
              child: Container(
                width: rs,
                height: rs,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(120 + (i % 3) * 40),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(80),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.withAlpha(60)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 16,
                              color: Colors.amber.shade300,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AuthService.instance.currentUsername ?? 'Player',
                              style: TextStyle(
                                color: Colors.amber.shade100,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Đăng xuất',
                        onPressed: () async {
                          await AuthService.instance.logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder: (_, anim, __) => const LoginScreen(),
                              transitionsBuilder: (_, anim, __, child) =>
                                  FadeTransition(opacity: anim, child: child),
                              transitionDuration: const Duration(
                                milliseconds: 400,
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.logout_rounded,
                          color: Colors.white.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Trophy icon
                const Text('🏆', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),

                // Game title
                ScaleTransition(
                  scale: _pulseAnim,
                  child: Column(
                    children: [
                      Text(
                        'ĐUA',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(180),
                              blurRadius: 12,
                              offset: const Offset(2, 4),
                            ),
                            Shadow(
                              color: const Color(0xFFFF8C00).withAlpha(200),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'BÒ',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 8,
                          shadows: [
                            Shadow(
                              color: Colors.black.withAlpha(180),
                              blurRadius: 12,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // Subtitle
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber.withAlpha(80)),
                  ),
                  child: const Text(
                    'Đặt cược · Đua bò · Thắng lớn!',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const Spacer(),

                // 3 cow idle images
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _cowPreview('assets/images/cow_brown_idle.png', offset: 8),
                    _cowPreview('assets/images/cow_milk_idle.png'),
                    _cowPreview('assets/images/cow_red_idle.png', offset: 8),
                  ],
                ),

                const SizedBox(height: 16),

                // Play button
                GestureDetector(
                  onTap: () {
                    _audio.stopBgm();
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (_, anim, __) => const GameScreen(),
                        transitionsBuilder: (_, anim, __, child) =>
                            FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/start_button.png',
                        height: 64,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent.withAlpha(100),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: const Text(
                            'CHƠI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Nhấn để bắt đầu',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Guide button
                GestureDetector(
                  onTap: () => setState(() => _showGuide = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.amber.withAlpha(120),
                        width: 1.5,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 8),
                        Text(
                          'HƯỚNG DẪN',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),

          // ── Guide overlay ──
          if (_showGuide) Positioned.fill(child: _buildGuideOverlay()),
        ],
      ),
    );
  }

  Widget _buildGuideOverlay() {
    return Container(
      color: const Color(0xEA071A07),
      child: SafeArea(
        child: Column(
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _showGuide = false),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.amber.withAlpha(60), height: 1),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Section 1: Giới thiệu ──
                    _guideSection(
                      icon: '',
                      title: 'Giới thiệu trò chơi',
                      content: [
                        'Đua Bò là trò chơi đặt cược đua bò thú vị dành cho mọi lứa tuổi.',
                        'Mỗi vòng đua có 3 chú bò tham gia: Bò Nâu, Bò Sữa và Bò Đỏ.',
                        'Người chơi bắt đầu với ${kInitialBalance} xu và đặt cược vào chú bò mình nghĩ sẽ thắng.',
                        'Nếu bò bạn chọn về nhất, bạn sẽ nhận được tiền thưởng gấp $kMultiplier lần số xu đặt cược!',
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Section 2: Hướng dẫn chơi ──
                    _guideSection(
                      icon: '',
                      title: 'Hướng dẫn chơi',
                      content: [
                        '1️⃣  Nhấn "START" để vào màn hình đặt cược.',
                        '2️⃣  Chọn số xu đặt cược cho từng chú bò bằng các nút + / −.',
                        '3️⃣  Nhấn "START" để phát lệnh xuất phát. Tiền cược sẽ bị trừ ngay lúc này.',
                        '4️⃣  Xem cuộc đua diễn ra — tốc độ mỗi bò được tính ngẫu nhiên mỗi vòng!',
                        '5️⃣  Sau khi có kết quả, bảng thắng/thua sẽ hiển thị số xu bạn nhận lại.',
                        '💡  Mẹo: Chia cược vào nhiều bò để tăng cơ hội thắng, nhưng lợi nhuận sẽ thấp hơn.',
                        '🆓  Hết xu? Nhấn "Nhận 1000 coins miễn phí" để chơi tiếp!',
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Close button at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: GestureDetector(
                onTap: () => setState(() => _showGuide = false),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFB300), Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withAlpha(80),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Đã hiểu!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideSection({
    required String icon,
    required String title,
    required List<String> content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...content.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cowPreview(String asset, {double offset = 0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: offset),
      child: Image.asset(
        asset,
        width: 72,
        height: 72,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox(width: 72, height: 72),
      ),
    );
  }
}

class _CowRunner {
  final String assetPrefix;
  double x;
  final double y;
  final double speed;
  final double size;
  int frame;

  _CowRunner({
    required this.assetPrefix,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.frame,
  });
}

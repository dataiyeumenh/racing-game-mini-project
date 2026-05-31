import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService.instance;

  bool _isRegister = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (_isRegister) {
      final error = await _auth.register(username, password);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error != null) {
        _showMessage(error, isError: true);
        return;
      }
      _goHome();
    } else {
      final ok = await _auth.login(username, password);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!ok) {
        _showMessage('Sai tên đăng nhập hoặc mật khẩu', isError: true);
        return;
      }
      _goHome();
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  void _showMessage(String text, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          ...List.generate(14, (i) {
            final rx = (i * 137.5) % 1.0;
            final ry = (i * 97.3) % 0.55;
            return Positioned(
              left: rx * size.width,
              top: ry * size.height,
              child: Container(
                width: 2 + (i % 3),
                height: 2 + (i % 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(80 + (i % 3) * 30),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _floatAnim,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: child,
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/cow_brown_idle.png',
                              width: 88,
                              height: 88,
                              errorBuilder: (_, _, _) => const Text(
                                '🐂',
                                style: TextStyle(fontSize: 72),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ĐUA BÒ',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 6,
                                color: Colors.amber.shade400,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withAlpha(180),
                                    blurRadius: 10,
                                    offset: const Offset(2, 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isRegister ? 'Tạo tài khoản mới' : 'Chào mừng trở lại!',
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTabSwitcher(),
                            const SizedBox(height: 24),
                            _buildField(
                              controller: _usernameController,
                              label: 'Tên đăng nhập',
                              icon: Icons.person_rounded,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Nhập tên đăng nhập';
                                }
                                if (_isRegister && v.trim().length < 3) {
                                  return 'Ít nhất 3 ký tự';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              controller: _passwordController,
                              label: 'Mật khẩu',
                              icon: Icons.lock_rounded,
                              obscure: _obscurePassword,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: Colors.amber.shade300,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Nhập mật khẩu';
                                }
                                if (_isRegister && v.length < 6) {
                                  return 'Ít nhất 6 ký tự';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildSubmitButton(),
                            if (!_isRegister) ...[
                              const SizedBox(height: 16),
                              _buildDemoHint(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A3A1A).withAlpha(230),
            const Color(0xFF0F2D0F).withAlpha(240),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.amber.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.amber.withAlpha(25),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(60),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tabButton('Đăng nhập', !_isRegister, () {
            setState(() => _isRegister = false);
          }),
          _tabButton('Đăng ký', _isRegister, () {
            setState(() => _isRegister = true);
          }),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.amber.shade700 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.amber.withAlpha(80),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.white54,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber.shade200.withAlpha(180)),
        prefixIcon: Icon(icon, color: Colors.amber.shade300, size: 22),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.black.withAlpha(50),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.amber.withAlpha(50)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.amber.shade400, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : _submit,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isLoading
                  ? [Colors.grey.shade600, Colors.grey.shade700]
                  : [const Color(0xFF2E7D32), const Color(0xFF1B5E20)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.withAlpha(100)),
            boxShadow: _isLoading
                ? null
                : [
                    BoxShadow(
                      color: Colors.greenAccent.withAlpha(80),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isRegister ? Icons.person_add_rounded : Icons.login_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isRegister ? 'TẠO TÀI KHOẢN' : 'VÀO SÂN ĐUA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(50)),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_rounded, color: Colors.amber.shade300, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo: player / 123456',
              style: TextStyle(
                color: Colors.amber.shade100.withAlpha(200),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
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
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: size.height * 0.22,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1E5C1E), Color(0xFF145214)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: size.height * 0.08,
          left: 0,
          right: 0,
          child: Container(
            height: size.height * 0.18,
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
      ],
    );
  }
}

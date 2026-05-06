// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../main.dart';

const _brand = Color.fromARGB(255, 125, 125, 255);

// ─── Luffy image states ───────────────────────────────────────────────────────
//  idle        → luffy_peek.png        (default, no focus)
//  focused     → luffy_cover.png       (any field clicked/focused)
//  typingNonPw → luffy_peek_scared.png (typing in non-password field)

enum _LuffyState { idle, focused, typingNonPw }

// ─── Public entry points ──────────────────────────────────────────────────────

Future<void> showLoginModal(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _AuthDialog(mode: _AuthMode.login),
    );

Future<void> showRegisterModal(BuildContext context) => showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _AuthDialog(mode: _AuthMode.register),
    );

// ─── Mode ─────────────────────────────────────────────────────────────────────

enum _AuthMode { login, register }

// ─── Dialog ───────────────────────────────────────────────────────────────────

class _AuthDialog extends StatefulWidget {
  final _AuthMode mode;
  const _AuthDialog({required this.mode});

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog>
    with SingleTickerProviderStateMixin {
  // controllers
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // focus nodes — one per field
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;

  // bounce animation
  late final AnimationController _bounce;
  late final Animation<double> _bounceY;

  // ── Derive Luffy state ────────────────────────────────────────────────────
  _LuffyState get _luffyState {
    final pwFocused = _passwordFocus.hasFocus || _confirmFocus.hasFocus;
    final nonPwFocused = _usernameFocus.hasFocus || _emailFocus.hasFocus;
    final anyFocused = pwFocused || nonPwFocused;

    // Typing in a non-password field (has text AND that field is focused)
    final typingNonPw = nonPwFocused &&
        (_usernameCtrl.text.isNotEmpty || _emailCtrl.text.isNotEmpty);

    if (typingNonPw) return _LuffyState.typingNonPw;
    if (anyFocused) return _LuffyState.focused;
    return _LuffyState.idle;
  }

  String get _luffyImage {
    switch (_luffyState) {
      case _LuffyState.typingNonPw:
        return 'assets/images/luffy_peek_scared.png';
      case _LuffyState.focused:
        return 'assets/images/luffy_cover.png';
      case _LuffyState.idle:
        return 'assets/images/luffy_peek.png';
    }
  }

  void _onFocusChange() => setState(() {});

  @override
  void initState() {
    super.initState();

    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _bounceY = Tween<double>(begin: 0, end: -1).animate(
      CurvedAnimation(parent: _bounce, curve: Curves.easeInOut),
    );

    // Listen to focus changes to trigger image swap
    for (final f in [_usernameFocus, _emailFocus, _passwordFocus, _confirmFocus]) {
      f.addListener(_onFocusChange);
    }

    // Listen to text changes for typingNonPw detection
    for (final c in [_usernameCtrl, _emailCtrl, _passwordCtrl, _confirmCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    for (final f in [_usernameFocus, _emailFocus, _passwordFocus, _confirmFocus]) {
      f.removeListener(_onFocusChange);
      f.dispose();
    }
    for (final c in [_usernameCtrl, _emailCtrl, _passwordCtrl, _confirmCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (widget.mode == _AuthMode.login) {
        await AuthService.instance.login(
          emailOrUsername: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      } else {
        if (_passwordCtrl.text != _confirmCtrl.text) {
          throw const AuthException('Passwords do not match.');
        }
        await AuthService.instance.register(
          username: _usernameCtrl.text,
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
      }
      if (!mounted) return;
      MyApp.of(context).notifyAuthChanged();
      Navigator.pop(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _switchMode() {
    Navigator.pop(context);
    if (widget.mode == _AuthMode.login) {
      showRegisterModal(context);
    } else {
      showLoginModal(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1a1a2e) : Colors.white;
    final hintCol = isDark ? Colors.white38 : Colors.black38;
    final isLogin = widget.mode == _AuthMode.login;
    final luffyState = _luffyState;
    // Only bounce on idle/focused states — no bounce when scared
    final isBouncing = luffyState != _LuffyState.typingNonPw;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // ── Luffy image — rendered first so card always sits on top ──────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _bounceY,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, isBouncing ? _bounceY.value : 0),
                  child: child,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 120),
                  child: Image.asset(
                    _luffyImage,
                    key: ValueKey(_luffyImage),
                    width: 180,
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // ── Card ────────────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 120),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _brand.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, color: hintCol, size: 20),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLogin ? 'Welcome Back!' : 'Create Account',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Naruto',
                      color: _brand,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLogin ? 'Sign in to continue' : 'Join Cool To! today',
                    style: TextStyle(fontSize: 13, color: hintCol),
                  ),
                  const SizedBox(height: 20),

                  // ── Fields ──────────────────────────────────────────────
                  if (!isLogin) ...[
                    _Field(
                      controller: _usernameCtrl,
                      focusNode: _usernameFocus,
                      hint: 'Username',
                      icon: Icons.person_outline,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                  ],
                  _Field(
                    controller: _emailCtrl,
                    focusNode: _emailFocus,
                    hint: isLogin ? 'Email or Username' : 'Email',
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _Field(
                    controller: _passwordCtrl,
                    focusNode: _passwordFocus,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isDark: isDark,
                    obscure: _obscurePassword,
                    onToggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  if (!isLogin) ...[
                    const SizedBox(height: 12),
                    _Field(
                      controller: _confirmCtrl,
                      focusNode: _confirmFocus,
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline,
                      isDark: isDark,
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      onSubmitted: (_) => _submit(),
                    ),
                  ],

                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brand,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLogin ? 'Sign In' : 'Register',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin
                            ? "Don't have an account? "
                            : 'Already have an account? ',
                        style: TextStyle(fontSize: 13, color: hintCol),
                      ),
                      GestureDetector(
                        onTap: _switchMode,
                        child: Text(
                          isLogin ? 'Register' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _brand,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ─── Reusable field ───────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool? obscure;
  final VoidCallback? onToggle;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const _Field({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscure,
    this.onToggle,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = _brand.withOpacity(0.4);
    final fillColor = isDark
        ? Colors.white.withOpacity(0.05)
        : const Color.fromARGB(255, 125, 125, 255).withOpacity(0.04);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure ?? false,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        prefixIcon: Icon(icon, size: 18, color: _brand),
        suffixIcon: obscure != null
            ? IconButton(
                icon: Icon(
                  obscure! ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: _brand,
                ),
                onPressed: onToggle,
              )
            : null,
        filled: true,
        fillColor: fillColor,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _brand, width: 1.5),
        ),
      ),
    );
  }
}

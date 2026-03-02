import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'SignUpEmail.dart';
import 'SignIn.dart';
import 'CongratsPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _loading = false;

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CongratulationsPage()),
            (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF86C340);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const SizedBox(height: 18),
              const Icon(Icons.eco, size: 64, color: Color(0xFF2E6B2E)),
              const SizedBox(height: 8),
              const Text(
                "EcoBek",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              const Text(
                "Explore the app",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                "Now your finances are in one place\nand always under control",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Google
              _AuthButton(
                icon: Icons.g_mobiledata,
                label: "Continue with Google",
                onTap: _loading ? null : _google,
              ),
              const SizedBox(height: 10),

              // Apple (UI only)
              _AuthButton(
                icon: Icons.apple,
                label: "Continue with Apple",
                onTap: null,
                disabled: true,
              ),
              const SizedBox(height: 10),

              // Email
              _AuthButton(
                icon: Icons.email_outlined,
                label: "Continue with Email",
                onTap: _loading
                    ? null
                    : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpEmailPage()),
                  );
                },
              ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                      );
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                        color: green,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool disabled;

  const _AuthButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          disabledBackgroundColor: Colors.white,
          disabledForegroundColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

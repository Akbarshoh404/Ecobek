import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'CongratsPage.dart';

class SignUpEmailPage extends StatefulWidget {
  const SignUpEmailPage({super.key});

  @override
  State<SignUpEmailPage> createState() => _SignUpEmailPageState();
}

class _SignUpEmailPageState extends State<SignUpEmailPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _accept = true; // your UI has it checked
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_accept) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept terms and privacy policy.")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.signUpWithEmail(
        username: _username.text,
        email: _email.text,
        password: _password.text,
      );

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                "Create account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),

              _Field(label: "Username", controller: _username, hint: "Your username"),
              const SizedBox(height: 12),
              _Field(label: "Email", controller: _email, hint: "Your email", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),

              Text("Password", style: TextStyle(color: Colors.black.withOpacity(0.7))),
              const SizedBox(height: 6),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _accept,
                    activeColor: green,
                    onChanged: (v) => setState(() => _accept = v ?? false),
                  ),
                  const Expanded(
                    child: Text("I accept the terms and privacy policy"),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _loading ? null : _signUp,
                  child: Text(_loading ? "Signing up..." : "Sing up"),
                ),
              ),

              const SizedBox(height: 22),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Already have an account? Log in",
                    style: TextStyle(color: green, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black.withOpacity(0.7))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

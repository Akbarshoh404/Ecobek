import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String _gender = "N/A";
  DateTime? _dob;

  String? _email;
  String? _photoUrl;

  File? _pickedImage;
  bool _loading = true;
  bool _saving = false;

  final _green = const Color(0xFF86C340);

  DatabaseReference get _userRef {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseDatabase.instance.ref('users/$uid');
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final snap = await FirebaseDatabase.instance.ref('users/$uid').get();
    final value = snap.value;

    final Map<String, dynamic> data = value is Map
        ? Map<String, dynamic>.from(value as Map)
        : <String, dynamic>{};

    final dateMsRaw = data['dateMs'];
    final int? dateMs = dateMsRaw is int ? dateMsRaw : (dateMsRaw is num ? dateMsRaw.toInt() : null);

    setState(() {
      _email = (data['email'] as String?) ?? FirebaseAuth.instance.currentUser?.email;
      _photoUrl = data['photo'] as String?;
      _name.text = (data['name'] as String?) ?? "";
      _phone.text = (data['phone'] as String?) ?? "";
      _gender = (data['gender'] as String?) ?? "N/A";
      _dob = dateMs == null ? null : DateTime.fromMillisecondsSinceEpoch(dateMs);
      _loading = false;
    });
  }

  // Gallery only (enough). If you want camera too, tell me and I’ll add it.
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x == null) return;
    setState(() => _pickedImage = File(x.path));
  }

  Future<String?> _uploadPhoto(String uid) async {
    if (_pickedImage == null) return _photoUrl;

    final ref = FirebaseStorage.instance.ref().child("user_photos/$uid/profile.jpg");
    await ref.putFile(_pickedImage!);
    return await ref.getDownloadURL();
  }

  String _dobLabel() {
    if (_dob == null) return "N/A";
    final d = _dob!;
    const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return "${d.day.toString().padLeft(2, '0')} - ${months[d.month - 1]} - ${d.year}";
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 18, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (picked == null) return;
    setState(() => _dob = picked);
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _saving = true);
    try {
      final url = await _uploadPhoto(uid);
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      await FirebaseDatabase.instance.ref('users/$uid').update({
        'name': _name.text.trim().isEmpty ? null : _name.text.trim(),
        'email': _email, // keep email in DB (optional)
        'photo': url,
        'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        'gender': (_gender == "N/A") ? null : _gender,
        'dateMs': _dob == null ? null : _dob!.millisecondsSinceEpoch,
        'updatedAt': nowMs,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_photoUrl != null && _photoUrl!.isNotEmpty)
                        ? NetworkImage(_photoUrl!) as ImageProvider
                        : null,
                    child: (_pickedImage == null && (_photoUrl == null || _photoUrl!.isEmpty))
                        ? const Icon(Icons.person, size: 36, color: Colors.black54)
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            _label("Full Name"),
            _textField(_name, hint: "Your name"),
            const SizedBox(height: 12),

            _label("Email"),
            _textField(TextEditingController(text: _email ?? ""), readOnly: true),
            const SizedBox(height: 12),

            _label("Phone"),
            _textField(_phone, hint: "Phone number", keyboardType: TextInputType.phone),
            const SizedBox(height: 12),

            _label("Gender"),
            DropdownButtonFormField<String>(
              value: _gender,
              items: const [
                DropdownMenuItem(value: "N/A", child: Text("N/A")),
                DropdownMenuItem(value: "Male", child: Text("Male")),
                DropdownMenuItem(value: "Female", child: Text("Female")),
                DropdownMenuItem(value: "Other", child: Text("Other")),
              ],
              onChanged: (v) => setState(() => _gender = v ?? "N/A"),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            _label("Date of Birth"),
            GestureDetector(
              onTap: _pickDob,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: _dobLabel(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: const Icon(Icons.calendar_month),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _saving ? null : _save,
                child: Text(_saving ? "Saving..." : "Save"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _textField(
      TextEditingController c, {
        String? hint,
        bool readOnly = false,
        TextInputType? keyboardType,
      }) {
    return TextField(
      controller: c,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import 'web_portal_screen.dart';

class ServerSetupScreen extends StatefulWidget {
  const ServerSetupScreen({super.key, this.initialUrl = ''});

  final String initialUrl;

  @override
  State<ServerSetupScreen> createState() => _ServerSetupScreenState();
}

class _ServerSetupScreenState extends State<ServerSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _urlController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    var url = value.trim();
    if (url.isNotEmpty && !url.endsWith('/')) url = '$url/';
    return url;
  }

  String? _validate(String? value) {
    final url = _normalize(value ?? '');
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) {
      return 'กรุณากรอก URL ระบบ เช่น https://example.com/transport/';
    }
    final localHost = uri.host == 'localhost' || uri.host == '127.0.0.1';
    if (uri.scheme != 'https' && !(localHost && uri.scheme == 'http')) {
      return 'ระบบจริงควรใช้ HTTPS เพื่อปกป้องข้อมูลลูกค้าและรหัสผ่าน';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final url = _normalize(_urlController.text);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transport_base_url', url);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => WebPortalScreen(baseUrl: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  Image.asset('assets/images/app_logo.png', height: 140),
                  const SizedBox(height: 4),
                  const Text(
                    'แอพขนส่ง',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'เชื่อมต่อระบบขนส่ง v19 เดิม\nLogin เดียวกันสำหรับทุกฝ่าย',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color(0xFFD8E2F0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'URL ระบบเว็บ',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'กรอก URL โฟลเดอร์ที่มี login.php ของระบบ v19',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _urlController,
                              keyboardType: TextInputType.url,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.language),
                                hintText: 'https://your-domain.com/transport/',
                              ),
                              validator: _validate,
                            ),
                            const SizedBox(height: 14),
                            FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 13),
                                child: Text('เชื่อมต่อและเปิดแอพ'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _RoleChip('Admin'),
                      _RoleChip('คนรถ'),
                      _RoleChip('ฝ่ายขาย'),
                      _RoleChip('ฝ่ายจัดซื้อ'),
                      _RoleChip('ฝ่ายดูแลระบบ'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 18, color: AppTheme.primary),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'แนะนำให้ใช้ HTTPS เท่านั้นสำหรับระบบจริง',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const Icon(Icons.verified_user_outlined, size: 17, color: AppTheme.primary),
      label: Text(label),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFD8E2F0)),
    );
  }
}

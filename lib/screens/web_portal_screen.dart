import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/download_service.dart';
import '../services/permissions_service.dart';
import '../theme/app_theme.dart';
import 'server_setup_screen.dart';

class WebPortalScreen extends StatefulWidget {
  const WebPortalScreen({super.key, required this.baseUrl});
  final String baseUrl;

  @override
  State<WebPortalScreen> createState() => _WebPortalScreenState();
}

class _WebPortalScreenState extends State<WebPortalScreen> {
  InAppWebViewController? _controller;
  double _progress = 0;
  bool _mainFrameError = false;
  String _errorText = '';

  late final PullToRefreshController _pullToRefreshController = PullToRefreshController(
    settings: PullToRefreshSettings(color: AppTheme.primary),
    onRefresh: () async {
      await _controller?.reload();
    },
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PermissionsService.requestCorePermissions();
    });
  }

  bool _shouldOpenExternally(WebUri uri) {
    final scheme = uri.scheme.toLowerCase();
    if (!['http', 'https', 'about', 'data', 'file'].contains(scheme)) return true;

    final host = uri.host.toLowerCase();
    return host.contains('google.com') ||
        host.contains('google.co.th') ||
        host == 'maps.app.goo.gl' ||
        host == 'line.me' ||
        host.endsWith('.line.me');
  }

  Future<NavigationActionPolicy> _navigation(NavigationAction action) async {
    final uri = action.request.url;
    if (uri == null) return NavigationActionPolicy.ALLOW;

    if (_shouldOpenExternally(uri)) {
      final target = Uri.parse(uri.toString());
      if (await canLaunchUrl(target)) {
        await launchUrl(target, mode: LaunchMode.externalApplication);
        return NavigationActionPolicy.CANCEL;
      }
    }
    return NavigationActionPolicy.ALLOW;
  }

  Future<void> _changeServer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transport_base_url');
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ServerSetupScreen(initialUrl: widget.baseUrl)),
    );
  }

  Future<void> _home() async {
    setState(() {
      _mainFrameError = false;
      _errorText = '';
    });
    await _controller?.loadUrl(urlRequest: URLRequest(url: WebUri(widget.baseUrl)));
  }

  @override
  Widget build(BuildContext context) {
    final initial = WebUri(widget.baseUrl);

    return WillPopScope(
      onWillPop: () async {
        if (await _controller?.canGoBack() ?? false) {
          await _controller?.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          titleSpacing: 12,
          title: const Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('แอพขนส่ง', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          actions: [
            IconButton(tooltip: 'หน้าหลัก', onPressed: _home, icon: const Icon(Icons.home_outlined)),
            IconButton(
              tooltip: 'รีเฟรช',
              onPressed: () => _controller?.reload(),
              icon: const Icon(Icons.refresh_rounded),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'server') _changeServer();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'server',
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.dns_outlined),
                    title: Text('เปลี่ยน URL ระบบ'),
                  ),
                ),
              ],
            ),
          ],
          bottom: _progress < 1
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(value: _progress > 0 ? _progress : null, minHeight: 2),
                )
              : null,
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: initial),
              pullToRefreshController: _pullToRefreshController,
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
                supportZoom: false,
                useShouldOverrideUrlLoading: true,
                useOnDownloadStart: true,
                supportMultipleWindows: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                allowsBackForwardNavigationGestures: true,
                cacheEnabled: true,
                thirdPartyCookiesEnabled: true,
                domStorageEnabled: true,
                databaseEnabled: true,
                geolocationEnabled: true,
                builtInZoomControls: false,
                displayZoomControls: false,
                transparentBackground: false,
              ),
              onWebViewCreated: (controller) => _controller = controller,
              shouldOverrideUrlLoading: (controller, action) => _navigation(action),
              onCreateWindow: (controller, createWindowAction) async {
                final uri = createWindowAction.request.url;
                if (uri == null) return false;
                if (_shouldOpenExternally(uri)) {
                  final target = Uri.parse(uri.toString());
                  if (await canLaunchUrl(target)) {
                    await launchUrl(target, mode: LaunchMode.externalApplication);
                    return true;
                  }
                }
                await controller.loadUrl(urlRequest: URLRequest(url: uri));
                return true;
              },
              onProgressChanged: (controller, progress) {
                if (mounted) setState(() => _progress = progress / 100);
                if (Platform.isAndroid && progress == 100) {
                  _pullToRefreshController.endRefreshing();
                }
              },
              onLoadStop: (controller, url) async {
                _pullToRefreshController.endRefreshing();
                if (mounted) {
                  setState(() {
                    _progress = 1;
                    _mainFrameError = false;
                    _errorText = '';
                  });
                }
              },
              onReceivedError: (controller, request, error) {
                if (request.isForMainFrame == true && mounted) {
                  setState(() {
                    _mainFrameError = true;
                    _errorText = error.description;
                  });
                }
              },
              onPermissionRequest: (controller, request) async {
                await PermissionsService.requestCorePermissions();
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                await PermissionsService.requestCorePermissions();
                return GeolocationPermissionShowPromptResponse(
                  origin: origin,
                  allow: true,
                  retain: true,
                );
              },
              onDownloadStartRequest: (controller, request) async {
                await DownloadService.download(context, request);
              },
            ),
            if (_mainFrameError)
              Positioned.fill(
                child: ColoredBox(
                  color: AppTheme.surface,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded, size: 70, color: Color(0xFF64748B)),
                            const SizedBox(height: 18),
                            const Text(
                              'เชื่อมต่อระบบไม่ได้',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.navy),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorText.isEmpty ? 'กรุณาตรวจสอบอินเทอร์เน็ตและ URL ระบบ' : _errorText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _home,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('ลองใหม่'),
                            ),
                            TextButton(
                              onPressed: _changeServer,
                              child: const Text('แก้ไข URL ระบบ'),
                            ),
                          ],
                        ),
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
}

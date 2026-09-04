import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  static String _safeFileName(String name) {
    final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return cleaned.isEmpty ? 'download_${DateTime.now().millisecondsSinceEpoch}' : cleaned;
  }

  static Future<void> download(
    BuildContext context,
    DownloadStartRequest request,
  ) async {
    final url = request.url;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final cookies = await CookieManager.instance().getCookies(url: url);
      final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');

      final docs = await getApplicationDocumentsDirectory();
      final downloads = Directory('${docs.path}${Platform.pathSeparator}downloads');
      if (!await downloads.exists()) await downloads.create(recursive: true);

      final fallback = url.pathSegments.isNotEmpty && url.pathSegments.last.isNotEmpty
          ? url.pathSegments.last
          : 'download_${DateTime.now().millisecondsSinceEpoch}';
      final fileName = _safeFileName(request.suggestedFilename ?? fallback);
      final savePath = '${downloads.path}${Platform.pathSeparator}$fileName';

      messenger.showSnackBar(
        SnackBar(content: Text('กำลังดาวน์โหลด $fileName ...')),
      );

      await Dio().download(
        url.toString(),
        savePath,
        options: Options(
          headers: cookieHeader.isEmpty ? null : {'Cookie': cookieHeader},
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('ดาวน์โหลดแล้ว: $fileName'),
          action: SnackBarAction(
            label: 'เปิดไฟล์',
            onPressed: () => OpenFilex.open(savePath),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('ดาวน์โหลดไม่สำเร็จ: $e')),
      );
    }
  }
}

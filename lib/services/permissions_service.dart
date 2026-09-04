import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<void> requestCorePermissions() async {
    // เว็บ v19 ใช้ GPS ตอนเริ่ม/ปิดงาน และ input=file อาจเรียกกล้อง/ไมค์
    await <Permission>[
      Permission.locationWhenInUse,
      Permission.camera,
      Permission.microphone,
    ].request();
  }
}

# แอพขนส่ง — Android + iPhone

แพ็กเกจนี้คือซอร์สแอพ Flutter สำหรับใช้งานจริงกับระบบขนส่งเว็บ **v19** เดิม โดยแอพไม่สร้างฐานข้อมูลใหม่และไม่ย้ายข้อมูลออกจาก MySQL/MariaDB เดิม

## หลักการทำงาน

`แอพ Flutter → HTTPS → ระบบเว็บ v19 → MySQL/MariaDB เดิม`

ผู้ใช้ Login ด้วย Username/Password ชุดเดิม หน้าเว็บตรวจ Role เหมือนเดิม จึงใช้ได้ทั้ง Admin, คนรถ, ฝ่ายขาย, ฝ่ายจัดซื้อ และฝ่ายดูแลระบบ

## สิ่งที่แอพรองรับแล้ว

- เปิดเว็บระบบเดิมแบบเต็มจอใน Native WebView
- Cookie/Session Login ต่อเนื่อง
- กล้อง / เลือกรูป / แนบไฟล์
- GPS while-in-use สำหรับเริ่มงานและปิดงาน
- `tel:` โทรลูกค้า
- LINE / Google Maps เปิดแอพภายนอก
- Pull to refresh / ปุ่มรีเฟรช / กลับหน้าก่อนหน้า
- ดาวน์โหลดไฟล์โดยส่ง Cookie จาก WebView ไปด้วย เหมาะกับเอกสาร/Backup ที่ต้อง Login
- ตั้ง URL Server ครั้งแรกและจำค่าไว้ในเครื่อง
- เปลี่ยน URL Server ได้จากเมนูของแอพ
- App icon + splash ชื่อ **แอพขนส่ง**

## ก่อน Build ต้องมี

### Android
- Flutter stable
- Android Studio + Android SDK
- Java/JDK ตามที่ Flutter รุ่นนั้นกำหนด

### iPhone
- macOS
- Xcode
- Flutter stable
- Apple Developer Account สำหรับเซ็นแอพจริง/ขึ้น TestFlight/App Store

> เครื่อง build ใน ChatGPT session นี้ไม่มี Flutter SDK, Android SDK และ Xcode จึงไม่สามารถสร้าง APK/IPA ที่เซ็นแล้วจากที่นี่ได้ แต่ซอร์สแอพและสคริปต์เตรียมโปรเจกต์ให้ครบแล้ว

## เตรียมโปรเจกต์ครั้งแรก

### macOS / Linux

```bash
./tool/setup_project.sh
```

### Windows

```bat
tool\setup_project.bat
```

สคริปต์จะ:
1. สร้างโครง Android + iOS จาก Flutter
2. ใส่ permission กล้อง / GPS / ไมค์
3. ตั้งชื่อ **แอพขนส่ง**
4. ใส่ App Icon / Splash
5. `flutter pub get`
6. ตรวจ `flutter analyze`

## Build Android

```bash
flutter build apk --release
```

ไฟล์จะอยู่ประมาณ:

`build/app/outputs/flutter-apk/app-release.apk`

สำหรับ Play Store:

```bash
flutter build appbundle --release
```

## Build iPhone

บน Mac:

```bash
flutter build ipa --release
```

จากนั้นเซ็นด้วย Apple Developer Team ใน Xcode / App Store Connect

## ตั้ง URL ระบบ

ครั้งแรกแอพจะถาม URL ที่มีระบบ v19 เช่น:

`https://example.com/transport/`

URL นี้ควรเปิด `login.php` ของระบบได้ และควรเป็น HTTPS

ถ้าต้องการฝัง URL ตอน Build ไม่ให้ผู้ใช้กรอก:

```bash
flutter build apk --release --dart-define=TRANSPORT_BASE_URL=https://example.com/transport/
```

และ iOS:

```bash
flutter build ipa --release --dart-define=TRANSPORT_BASE_URL=https://example.com/transport/
```

## ข้อจำกัด v1 ที่ต้องรู้

ระบบ v19 เดิมติดตาม GPS ผ่านหน้าเว็บ ดังนั้น v1 นี้ติดตาม GPS ได้ขณะเปิดแอพ/หน้าเว็บทำงาน แต่ **ยังไม่ใช่ background tracking แท้เมื่อปิดหน้าจอเป็นเวลานาน** หากต้องการให้ติดตามต่อแม้จอดับ ต้องทำ native background location + API ฝั่ง server เพิ่มเป็นรุ่นถัดไป

Push Notification เช่น “มีงานใหม่ / ลูกค้าติดต่อไม่ได้ / งาน 5 ดาว” ก็ต้องเพิ่ม Firebase/APNs และ endpoint ฝั่ง server แยกจาก v19

## โครงสร้างสำคัญ

- `lib/main.dart` — เริ่มแอพ/โหลด URL ที่บันทึกไว้
- `lib/screens/server_setup_screen.dart` — ตั้ง URL Server ครั้งแรก
- `lib/screens/web_portal_screen.dart` — WebView หลัก
- `lib/services/download_service.dart` — ดาวน์โหลดไฟล์ด้วย session cookie
- `lib/services/permissions_service.dart` — permission GPS/กล้อง/ไมค์
- `assets/images/app_icon_1024.png` — ไอคอนแอพ
- `tool/setup_project.*` — สร้าง Android/iOS platform project
- `tool/patch_platforms.py` — permission และ App Display Name

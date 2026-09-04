#!/usr/bin/env python3
from pathlib import Path
import plistlib
import re

ROOT = Path(__file__).resolve().parents[1]

# AndroidManifest.xml
manifest = ROOT / 'android/app/src/main/AndroidManifest.xml'
if manifest.exists():
    text = manifest.read_text(encoding='utf-8')
    perms = [
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.CAMERA',
        'android.permission.RECORD_AUDIO',
        'android.permission.ACCESS_COARSE_LOCATION',
        'android.permission.ACCESS_FINE_LOCATION',
    ]
    for perm in reversed(perms):
        tag = f'<uses-permission android:name="{perm}" />'
        if perm not in text:
            pos = text.find('<application')
            text = text[:pos] + '    ' + tag + '\n' + text[pos:]
    text = re.sub(r'android:label="[^"]*"', 'android:label="แอพขนส่ง"', text, count=1)
    if 'android:usesCleartextTraffic=' not in text:
        text = text.replace('<application', '<application\n        android:usesCleartextTraffic="false"', 1)

    # Android 11+ package visibility for external schemes used by the web system.
    if '<queries>' not in text:
        queries = '''    <queries>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
        <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="line"/></intent>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="google.navigation"/></intent>
    </queries>
'''
        pos = text.find('<application')
        text = text[:pos] + queries + text[pos:]
    manifest.write_text(text, encoding='utf-8')

# iOS Info.plist
plist_path = ROOT / 'ios/Runner/Info.plist'
if plist_path.exists():
    with plist_path.open('rb') as f:
        data = plistlib.load(f)
    data['CFBundleDisplayName'] = 'แอพขนส่ง'
    data['CFBundleName'] = 'แอพขนส่ง'
    data['NSCameraUsageDescription'] = 'ใช้กล้องเพื่อถ่ายรูปหลักฐานและแนบรูปในงานขนส่ง'
    data['NSMicrophoneUsageDescription'] = 'ใช้ไมโครโฟนเมื่อแนบวิดีโอหลักฐานจากกล้อง'
    data['NSLocationWhenInUseUsageDescription'] = 'ใช้ตำแหน่งเพื่อเริ่มงาน ติดตามงาน และบันทึกตำแหน่งตอนปิดงาน'
    data['NSPhotoLibraryUsageDescription'] = 'เลือกรูปและเอกสารประกอบงานขนส่งจากคลังรูป'
    data['NSPhotoLibraryAddUsageDescription'] = 'บันทึกไฟล์หรือรูปที่ดาวน์โหลดจากระบบลงในอุปกรณ์'
    data['LSApplicationQueriesSchemes'] = list(dict.fromkeys((data.get('LSApplicationQueriesSchemes') or []) + [
        'tel', 'sms', 'line', 'googlemaps', 'comgooglemaps'
    ]))
    with plist_path.open('wb') as f:
        plistlib.dump(data, f, sort_keys=False)

# iOS deployment target in Podfile
podfile = ROOT / 'ios/Podfile'
if podfile.exists():
    text = podfile.read_text(encoding='utf-8')
    if re.search(r"platform :ios, '[^']+'", text):
        text = re.sub(r"platform :ios, '[^']+'", "platform :ios, '13.0'", text, count=1)
    elif "# platform :ios" in text:
        text = re.sub(r"# platform :ios, '[^']+'", "platform :ios, '13.0'", text, count=1)
    else:
        text = "platform :ios, '13.0'\n" + text
    podfile.write_text(text, encoding='utf-8')

print('Platform configuration patched successfully.')

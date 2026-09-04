แอพขนส่ง v1.0 — Android + iPhone

1) แอพนี้ต่อกับระบบเว็บ v19 เดิม ใช้ฐานข้อมูลเดิมและ Login เดิมทุกฝ่าย
2) ครั้งแรกกรอก URL เช่น https://your-domain.com/transport/
3) รองรับ Admin / คนรถ / ฝ่ายขาย / ฝ่ายจัดซื้อ / ฝ่ายดูแลระบบ
4) กล้อง, แนบรูป/ไฟล์, GPS ขณะเปิดแอพ, โทร, LINE, Google Maps และดาวน์โหลดเอกสารรองรับแล้ว
5) สร้าง Android/iOS project ครั้งแรก:
   macOS/Linux: ./tool/setup_project.sh
   Windows: tool\setup_project.bat
6) Android APK: flutter build apk --release
7) iPhone IPA: flutter build ipa --release (ต้องใช้ Mac + Xcode + Apple Developer signing)

หมายเหตุสำคัญ:
- ควรใช้ HTTPS
- Background GPS ตอนจอดับและ Push Notification ยังต้องทำ server API/native module เพิ่มในรุ่นถัดไป
- เครื่องมือใน ChatGPT session นี้ไม่มี Flutter/Android SDK/Xcode จึงไม่ได้แนบ APK/IPA ที่เซ็นแล้ว

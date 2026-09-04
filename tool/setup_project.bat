@echo off
setlocal
cd /d %~dp0\..
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERROR: ไม่พบ Flutter SDK ใน PATH
  echo ติดตั้ง Flutter stable ก่อน แล้วรันใหม่
  exit /b 1
)

if not exist _backup mkdir _backup
xcopy /E /I /Y lib _backup\lib >nul
xcopy /E /I /Y assets _backup\assets >nul
copy /Y pubspec.yaml _backup\pubspec.yaml >nul
copy /Y analysis_options.yaml _backup\analysis_options.yaml >nul

flutter create --org com.appkhonsong --project-name appkhonsong --platforms android,ios .

rmdir /S /Q lib
rmdir /S /Q assets
xcopy /E /I /Y _backup\lib lib >nul
xcopy /E /I /Y _backup\assets assets >nul
copy /Y _backup\pubspec.yaml pubspec.yaml >nul
copy /Y _backup\analysis_options.yaml analysis_options.yaml >nul
rmdir /S /Q _backup

python tool\patch_platforms.py
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter analyze

echo.
echo พร้อมแล้ว
echo Android: flutter build apk --release
echo iPhone ต้อง build บน macOS: flutter build ipa --release
endlocal

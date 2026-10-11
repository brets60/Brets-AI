@echo off
echo ========================================================
echo          Building Breta AI Android APK Package
echo ========================================================
echo Running flutter build apk --debug...
flutter build apk --debug
echo.
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ========================================================
    echo SUCCESS! Your APK is ready at:
    echo build\app\outputs\flutter-apk\app-debug.apk
    echo ========================================================
    copy "build\app\outputs\flutter-apk\app-debug.apk" "Breta-AI.apk"
    echo Copied to project root: Breta-AI.apk
)
pause

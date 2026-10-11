@echo off
echo ========================================================
echo        BRETA AI — PHONE ACCESS & INSTALL SERVER
echo ========================================================
echo.
echo Make sure your phone is connected to the same Wi-Fi!
echo.
echo On your Phone (Chrome on Android or Safari on iPhone):
echo Open this URL:
echo.
echo      http://192.168.2.24:5050
echo.
echo ========================================================
echo Once opened on your phone:
echo - On Android: Tap "Install App" or "Add to Home screen"
echo - On iPhone: Tap Share -> "Add to Home Screen"
echo ========================================================
echo.
echo Starting web server on port 5050...
python -m http.server 5050 --bind 0.0.0.0 --directory build/web
pause

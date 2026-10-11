@echo off
echo ========================================================
echo        Starting Breta AI Interactive Web Preview
echo ========================================================
echo Opening Breta AI in your default browser...
start http://localhost:5050
python -m http.server 5050 --directory build/web
pause

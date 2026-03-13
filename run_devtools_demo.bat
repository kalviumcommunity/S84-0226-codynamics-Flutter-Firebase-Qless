@echo off
echo ========================================
echo Flutter DevTools Demo Launcher
echo ========================================
echo.

echo Checking Flutter installation...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter is not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo Getting dependencies...
flutter pub get

echo.
echo ========================================
echo Starting Flutter app...
echo ========================================
echo.
echo Instructions:
echo - Press 'r' for Hot Reload
echo - Press 'R' for Hot Restart
echo - Press 'q' to Quit
echo - Open DevTools: Ctrl+Shift+P then "Dart: Open DevTools"
echo.
echo The app will launch with the DevTools demo screen.
echo Check the Debug Console for logs!
echo.

flutter run

pause

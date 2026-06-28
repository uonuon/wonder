@echo off
title Build Tarkeez APK
REM Rebuilds the Android debug APK into build\Tarkeez.apk
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7-stable_win64_console.exe"
if not exist build mkdir build
echo Exporting APK (this takes ~1 min)...
"%GODOT%" --headless --path "C:\Users\pc\tarkeez" --export-debug "Android" "C:\Users\pc\tarkeez\build\Tarkeez.apk"
echo.
if exist "build\Tarkeez.apk" (
  echo DONE -^> build\Tarkeez.apk
  echo Install on a USB-connected phone with:
  echo   "%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" install -r build\Tarkeez.apk
) else (
  echo Export failed - see messages above.
)
pause

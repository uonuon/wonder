@echo off
title Tarkeez (FAST TEST)
REM Fast mode: focus sessions run in SECONDS (a 25-min session = 25s) and a
REM "+session" button appears on Home to instantly grow the oasis for testing.
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7-stable_win64.exe"
if not exist "%GODOT%" (
  echo Could not find Godot at:
  echo   %GODOT%
  pause
  exit /b 1
)
"%GODOT%" --path "C:\Users\pc\tarkeez" -- --fast --noob
if errorlevel 1 pause

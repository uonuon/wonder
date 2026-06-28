@echo off
title Tarkeez (demo)
set "GODOT=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7-stable_win64.exe"
if not exist "%GODOT%" (
  echo Could not find Godot at:
  echo   %GODOT%
  pause
  exit /b 1
)
"%GODOT%" --path "C:\Users\pc\tarkeez" -- --demo --noob --stage=5
if errorlevel 1 pause

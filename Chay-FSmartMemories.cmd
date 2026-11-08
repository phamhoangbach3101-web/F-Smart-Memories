@echo off
setlocal
cd /d "%~dp0"
chcp 65001 >nul
title F Smart Memories - AI Photo Studio
if exist "FSmartMemories.exe" (
  start "" "%~dp0FSmartMemories.exe"
  exit /b
)
if not exist ".venv\Scripts\python.exe" (
  echo Chua cai dat. Chay: python scripts\bootstrap.py --with-local-chat --with-subject-tools
  pause
  exit /b 1
)
".venv\Scripts\python.exe" -u scripts\launch.py
if errorlevel 1 pause

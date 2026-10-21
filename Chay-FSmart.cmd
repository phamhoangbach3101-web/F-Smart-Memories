@echo off
chcp 65001 >nul
cd /d "%~dp0"
title F-Smart Memories
echo ========================================
echo F-SMART MEMORIES
echo ========================================
echo.
if not exist ".venv\Scripts\python.exe" (
  echo Chua co moi truong Python. Hay chay setup.ps1 truoc.
  pause
  exit /b 1
)
set PYTHONUNBUFFERED=1
set PYTHONIOENCODING=utf-8
echo Dang khoi dong. Trinh duyet se tu mo khi ung dung san sang.
echo Dia chi ung dung: http://127.0.0.1:8000
echo Giu cua so nay mo khi su dung ung dung.
echo.
".venv\Scripts\python.exe" -u scripts\launch.py
if errorlevel 1 (
  echo.
  echo Co loi khoi dong. Xem thong bao phia tren.
  pause
)

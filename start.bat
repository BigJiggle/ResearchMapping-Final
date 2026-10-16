@echo off
rem Research Map launcher for Windows: double-click to start.
rem Creates a local .venv on first run, installs requirements, then opens http://127.0.0.1:8000
setlocal
cd /d "%~dp0"

if exist ".venv\Scripts\python.exe" goto :deps

rem "python" on Windows is often the Microsoft Store stub, so prefer the py launcher.
set "PY="
where py >nul 2>nul && py -3 -c "import sys" >nul 2>nul && set "PY=py -3"
if not defined PY (
  python -c "import sys; assert sys.version_info >= (3, 10)" >nul 2>nul && set "PY=python"
)
if not defined PY (
  echo Python 3.10+ was not found. Install it from https://www.python.org/downloads/ and run this again.
  pause
  exit /b 1
)
echo Creating virtual environment...
%PY% -m venv .venv || (echo Could not create .venv & pause & exit /b 1)

:deps
rem Reinstall requirements only when requirements.txt changes.
fc /b requirements.txt ".venv\requirements.installed" >nul 2>nul
if errorlevel 1 (
  echo Installing requirements...
  ".venv\Scripts\python.exe" -m pip install --disable-pip-version-check -q -r requirements.txt || (echo Dependency install failed - check your internet connection. & pause & exit /b 1)
  copy /y requirements.txt ".venv\requirements.installed" >nul
)

rem AI runs on your Claude plan through Claude Code (no API key). Check it's signed in.
where claude >nul 2>nul || if not exist "%USERPROFILE%\.local\bin\claude.exe" (
  echo Note: Claude Code was not found, so AI features are off. Install it, then run: claude auth login
)

".venv\Scripts\python.exe" run.py
if errorlevel 1 pause

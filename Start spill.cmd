@echo off
setlocal
set "GODOT_EXE=C:\Users\perka\Downloads\Godot_v4.4.1-stable_win64.exe\Godot_v4.4.1-stable_win64.exe"
if not exist "%GODOT_EXE%" (
  echo Godot ble ikke funnet pa denne plasseringen.
  echo Apne Godot 4.4 eller nyere og importer project.godot fra denne mappen.
  pause
  exit /b 1
)
echo Klargjor Academic Defence ...
"%GODOT_EXE%" --headless --audio-driver Dummy --editor --path "%~dp0." --import
if errorlevel 1 (
  echo Prosjektet kunne ikke importeres. Se meldingen over.
  pause
  exit /b 1
)
start "Academic Defence" "%GODOT_EXE%" --path "%~dp0."
endlocal

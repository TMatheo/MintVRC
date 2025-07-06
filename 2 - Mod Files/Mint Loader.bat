@echo off
color A
>nul 2>&1 net session
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

title Mint Loader

setlocal enabledelayedexpansion

set "REGKEY=HKLM\SYSTEM\CurrentControlSet\Services\WinSock2\Parameters"
set "REGVALUE=AutodialDLL"

set "SCRIPT_DIR=%~dp0"
set "CUSTOM_DLL=%SCRIPT_DIR%Mint.dll"
set "CUSTOM_DLL=%CUSTOM_DLL:/=\%"
set "DEFAULT_DLL=C:\Windows\System32\rasadhlp.dll"

echo [Mint] Setting Autodial Path to %CUSTOM_DLL%...
reg add "%REGKEY%" /v "%REGVALUE%" /t REG_SZ /d "%CUSTOM_DLL%" /f >nul

if %ERRORLEVEL% neq 0 (
    echo Failed to set the registry value.
    pause
    exit /b
)

echo [Mint] Launch VRChat and DO NOT close this window...

:WAIT_LOOP
timeout /t 2 >nul
tasklist /fi "imagename eq VRChat.exe" | find /i "VRChat.exe" >nul
if errorlevel 1 goto WAIT_LOOP

echo [Mint] VRChat Detected, Waiting for game to fully load...
timeout /t 20 >nul

echo.
echo [Mint] Restoring Original Autodial Path to %DEFAULT_DLL%...
reg add "%REGKEY%" /v "%REGVALUE%" /t REG_SZ /d "%DEFAULT_DLL%" /f >nul

for /f "tokens=3*" %%a in ('reg query "%REGKEY%" /v "%REGVALUE%" 2^>nul') do set CURRENT=%%a

if /i "%CURRENT%"=="%DEFAULT_DLL%" (
    echo [Mint] Successfully restored AutodialDLL to: %DEFAULT_DLL%...
) else (
    echo [Mint] Failed to restore the correct value. Please check manually...
)

timeout /t 5 >nul
exit /b
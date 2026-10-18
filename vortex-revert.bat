@echo off
setlocal EnableDelayedExpansion
title Vortex Optimization Suite - Rollback and Revert Engine
color 0e

:: =======================================================================
:: 1. ADMINISTRATOR PRIVILEGE VERIFICATION
:: =======================================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0c
    echo =======================================================================
    echo  ERROR: ADMINISTRATOR PRIVILEGES REQUIRED
    echo =======================================================================
    echo This rollback script must be run as Administrator to restore Windows
    echo network stacks, registry keys, and system services.
    echo.
    echo Right-click 'vortex-revert.bat' and select 'Run as administrator'.
    echo =======================================================================
    pause
    exit /b 1
)

cls
echo =======================================================================
echo              VORTEX OPTIMIZATION - ROLLBACK AND REVERT
echo =======================================================================
echo This tool will restore Windows default networking and service settings:
echo   - Reset Network Adapters to DHCP and re-enable hardware offloads
echo   - Re-enable Interrupt Moderation, Flow Control, and Power Management
echo   - Remove all Vortex QoS DSCP 46 Policies and NLA workgroup overrides
echo   - Restore Windows Multimedia Network Throttling (0xa) and Responsiveness (0x14)
echo   - Reset TCP/IP and Winsock catalog stacks
echo   - Re-enable background services (DiagTrack, SysMain, WSearch)
echo.
echo NOTE: Power plans are never modified or touched by this utility.
echo.
set /p confirm="Are you sure you want to revert to Windows defaults? (Y/N): "
if /i "%confirm%" neq "Y" (
    echo [!] Rollback cancelled by user.
    pause
    exit /b 0
)

color 0b
echo.
echo =======================================================================
echo [1/4] RESTORING NETWORK ADAPTERS, QOS AND TCP/IP DEFAULTS...
echo =======================================================================

if exist "%~dp0vortex-net.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0vortex-net.ps1" -Mode Revert
) else (
    echo [*] Executing fallback PowerShell network revert...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& { Get-NetAdapter -Physical | ForEach-Object { Set-DnsClientServerAddress -InterfaceAlias $_.Name -ResetServerAddresses -ErrorAction SilentlyContinue; Enable-NetAdapterPowerManagement -Name $_.Name -ErrorAction SilentlyContinue; Enable-NetAdapterLso -Name $_.Name -IPv4 -IPv6 -ErrorAction SilentlyContinue; Enable-NetAdapterChecksumOffload -Name $_.Name -ErrorAction SilentlyContinue; Enable-NetAdapterRsc -Name $_.Name -IPv4 -IPv6 -ErrorAction SilentlyContinue }; Get-NetQosPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Vortex_*' } | Remove-NetQosPolicy -Confirm:$false -ErrorAction SilentlyContinue; Remove-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS' -Name 'Do not use NLA' -ErrorAction SilentlyContinue }"
)

echo.
echo =======================================================================
echo [2/4] RESETTING TCP/IP AND WINSOCK PROTOCOL CATALOGS...
echo =======================================================================
netsh int ip reset >nul 2>&1
netsh winsock reset >nul 2>&1
netsh int tcp reset >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global timestamps=allowed >nul 2>&1
netsh int tcp set heuristics enabled >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo [✓] TCP/IP, Winsock, and DNS resolver reset to system defaults.

echo.
echo =======================================================================
echo [3/4] RESTORING MULTIMEDIA THROTTLING AND SCHEDULING SETTINGS...
echo =======================================================================
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 10 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 20 /f >nul 2>&1

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "Medium" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "SFIO Priority" /t REG_SZ /d "Normal" /f >nul 2>&1

echo [✓] Multimedia throttling and gaming task priorities restored.

echo.
echo =======================================================================
echo [4/4] RE-ENABLING WINDOWS BACKGROUND SERVICES...
echo =======================================================================
sc config DiagTrack start= auto >nul 2>&1
sc start DiagTrack >nul 2>&1
sc config SysMain start= auto >nul 2>&1
sc start SysMain >nul 2>&1
sc config WSearch start= delayed-auto >nul 2>&1
sc start WSearch >nul 2>&1
echo [✓] DiagTrack, SysMain, and Windows Search re-enabled.

echo.
color 0a
echo =======================================================================
echo            VORTEX ROLLBACK COMPLETED SUCCESSFULLY
echo =======================================================================
echo All network stacks, adapter parameters, QoS rules, and background
echo services have been restored to Windows defaults.
echo.
echo NOTE: A system restart is recommended to re-bind network driver queues.
echo =======================================================================
pause
exit /b 0

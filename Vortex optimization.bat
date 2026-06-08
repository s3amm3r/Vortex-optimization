@echo off
setlocal EnableDelayedExpansion
title Vortex Optimization V1
color 0b

:: ==========================================
:: 1. ADMINISTRATOR CHECK & PROMPT
:: ==========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0c
    echo =====================================================
    echo  ERROR: ADMINISTRATOR PRIVILEGES REQUIRED
    echo =====================================================
    pause
    exit
)

cls
color 0e
echo =======================================================================
echo                VORTEX OPTIMIZATION SUITE v2 WARNING
echo =======================================================================
echo This script will execute deep kernel and network optimizations:
echo  - Stripping Network Adapter Hardware Offloads (RSC, VMQ, LSO, Checksum)
echo  - Modifying TCP/IP Congestion (CUBIC/CTCP) and Auto-Tuning protocols
echo  - Injecting QoS Policies (DSCP 46) for Fortnite traffic
echo  - Forcing Cloudflare DNS ^& DoH on active adapters
echo  - Suspending Windows Telemetry, Updates, and background services
echo.
set /p confirm="Do you want to proceed? (Y/N): "
if /i "%confirm%" neq "Y" (
    echo Optimization cancelled.
    pause
    exit
)
color 0b

:: ==========================================
:: 2. POWER & HARDWARE STATES
:: ==========================================
echo.
echo [1/6] CONFIGURING VORTEX POWER PROFILE...
echo ------------------------------------------------

for /f "tokens=4" %%a in ('powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61') do set ULT_GUID=%%a
if defined ULT_GUID ( 
    powercfg -setactive !ULT_GUID! 
) else ( 
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 
)

powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /SETACVALUEINDEX SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
powercfg -SetActive SCHEME_CURRENT

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Processor" /v ProcessorIdleDisable /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul

echo [✓] Vortex Power Profile Applied.

:: ==========================================
:: 3. NETWORK ADAPTER OPTIMIZATION
:: ==========================================
echo.
echo [2/6] APPLYING VORTEX NETWORK OPTIMIZATION...
echo ------------------------------------------------

set "PS_FILE=%TEMP%\VortexNet.ps1"
(
echo $adapters = Get-NetAdapter -Physical ^| Where-Object { $_.Status -eq 'Up' }
echo foreach ($a in $adapters) {
echo     $guid = $a.InterfaceGuid
echo     $name = $a.Name
echo     Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TcpAckFrequency" -Value 1 -ErrorAction SilentlyContinue
echo     Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TcpDelAckTicks" -Value 0 -ErrorAction SilentlyContinue
echo     Set-DnsClientServerAddress -InterfaceAlias $name -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue
echo     Set-DnsClientDohServerAddress -ServerAddresses "1.1.1.1" -DohTemplate "https://cloudflare-dns.com/dns-query" -ErrorAction SilentlyContinue
echo     netsh interface ipv4 set subinterface $name mtu=1500 store=persistent ^| Out-Null
echo     Disable-NetAdapterPowerManagement -Name $name -ErrorAction SilentlyContinue
echo     Disable-NetAdapterLso -Name $name -ErrorAction SilentlyContinue
echo     Disable-NetAdapterChecksumOffload -Name $name -IpIPv4 -TcpIPv4 -UdpIPv4 -ErrorAction SilentlyContinue
echo     Disable-NetAdapterRsc -Name $name -IPv4 -IPv6 -ErrorAction SilentlyContinue
echo     Disable-NetAdapterVmq -Name $name -ErrorAction SilentlyContinue
echo }
) > "%PS_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_FILE%"
del "%PS_FILE%"

echo [✓] Vortex Network Layer Optimized.

:: ==========================================
:: 4. TCP/IP STACK
:: ==========================================
echo.
echo [3/6] TUNING VORTEX TCP/IP STACK...
echo ------------------------------------------------

ipconfig /flushdns >nul
arp -d * >nul 2>&1
nbtstat -R >nul

netsh int tcp set global autotuninglevel=normal >nul
netsh int tcp set global congestionprovider=cubic >nul 2>&1
if %errorlevel% neq 0 netsh int tcp set global congestionprovider=ctcp >nul 2>&1

netsh int tcp set global timestamps=disabled >nul
netsh int tcp set global rss=enabled >nul

netsh interface teredo set state disabled >nul
netsh interface 6to4 set state disabled >nul
netsh interface isatap set state disabled >nul

echo [✓] Vortex TCP Stack Applied.

:: ==========================================
:: 5. CACHE CLEANUP
:: ==========================================
echo.
echo [4/6] CLEARING VORTEX CACHE LAYER...
echo ------------------------------------------------

del /q /f "%windir%\Prefetch\*Fortnite*.pf" >nul 2>&1
rmdir /s /q "%localappdata%\FortniteGame\Saved\webcache" >nul 2>&1
del /q /f /s "%localappdata%\D3DSCache\*" >nul 2>&1
del /q /f /s "%localappdata%\NVIDIA\DXCache\*" >nul 2>&1

echo [✓] Cache Layer Cleaned.

:: ==========================================
:: 6. GPU + SYSTEM OVERRIDES
:: ==========================================
echo.
echo [5/6] APPLYING VORTEX GPU PROFILE...
echo ------------------------------------------------

reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "FortniteClient-Win64-Shipping.exe" /t REG_SZ /d "GpuPreference=2;" /f >nul
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul

echo [✓] GPU Profile Set.

:: ==========================================
:: 7. BLOAT REMOVAL
:: ==========================================
echo.
echo [6/6] REMOVING BACKGROUND SERVICES...
echo ------------------------------------------------

taskkill /f /im OneDrive.exe >nul 2>&1
taskkill /f /im Cortana.exe >nul 2>&1
taskkill /f /im Skype.exe >nul 2>&1

sc config DiagTrack start= disabled >nul
sc config SysMain start= disabled >nul
sc config WSearch start= disabled >nul

echo [✓] Background Services Optimized.

:: ==========================================
:: COMPLETION
:: ==========================================
echo.
echo =========================================================
echo        VORTEX OPTIMIZATION COMPLETE
echo        RESTART RECOMMENDED FOR FULL EFFECT
echo =========================================================

set /p launch="Launch Fortnite now? (Y/N): "
if /i "%launch%"=="Y" (
    start "" /high "com.epicgames.launcher://apps/Fortnite?action=launch&silent=true"
)

exit
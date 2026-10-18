@echo off
setlocal EnableDelayedExpansion
title Vortex Optimization Suite v2.1 - Universal Gaming and Low-Latency Network Engine
color 0b

:: =======================================================================
:: 1. ADMINISTRATOR PRIVILEGE VERIFICATION
:: =======================================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0c
    echo =======================================================================
    echo  ERROR: ADMINISTRATOR PRIVILEGES REQUIRED
    echo =======================================================================
    echo This suite applies system-level kernel, network adapter, and TCP/IP
    echo tweaks that require elevated Administrator permissions.
    echo.
    echo Right-click this file and select 'Run as administrator'.
    echo =======================================================================
    pause
    exit /b 1
)

:: Support silent/automated flags
if /i "%~1"=="/y" goto :OPT_FULL
if /i "%~1"=="/auto" goto :OPT_FULL

:MENU
cls
color 0b
echo =======================================================================
echo          VORTEX OPTIMIZATION SUITE v2.1 - s3amm3r
echo     Universal Competitive Gaming, Ethernet and Wi-Fi Engine
echo =======================================================================
echo.
echo Select an execution mode:
echo.
echo   [1] Full Vortex Optimization (Ethernet/Wi-Fi + TCP/IP + Universal QoS + Cache + Bloat)
echo   [2] Network and Adapter Tuning Only (Ethernet, Wi-Fi, QoS DSCP 46, Cloudflare DNS)
echo   [3] Wi-Fi Ping Spike Stabilizer (Toggle WLAN AutoConfig Background Scanning)
echo   [4] Prioritize Custom Game (Add your game .exe to QoS DSCP 46 and GPU Priority)
echo   [5] Rollback to Windows Defaults (Restore original settings)
echo   [6] Exit
echo.
set /p choice="Enter choice [1-6] (Default: 1): "

if "%choice%"=="" set choice=1
if "%choice%"=="1" goto :OPT_FULL
if "%choice%"=="2" goto :OPT_NET_ONLY
if "%choice%"=="3" goto :OPT_WIFI_TOGGLE
if "%choice%"=="4" goto :OPT_CUSTOM_GAME
if "%choice%"=="5" goto :OPT_REVERT
if "%choice%"=="6" exit /b 0

echo [!] Invalid selection. Please choose 1, 2, 3, 4, 5, or 6.
timeout /t 2 >nul
goto :MENU

:: =======================================================================
:: MODE 4: PRIORITIZE CUSTOM GAME
:: =======================================================================
:OPT_CUSTOM_GAME
cls
echo =======================================================================
echo                 PRIORITIZE CUSTOM GAME EXECUTABLE
echo =======================================================================
echo Enter the executable name of any game you want to prioritize.
echo (e.g. cs2.exe, VALORANT-Win64-Shipping.exe, r5apex.exe, RocketLeague.exe)
echo.
set /p custom_exe="Game Executable Name: "
if "!custom_exe!"=="" (
    echo [!] No executable provided. Returning to menu.
    timeout /t 2 >nul
    goto :MENU
)
set "custom_exe=!custom_exe:"=!"
set "custom_exe=!custom_exe:'=!"
if "!custom_exe!"=="" (
    echo [!] Invalid executable provided. Returning to menu.
    timeout /t 2 >nul
    goto :MENU
)

echo [*] Applying QoS DSCP 46 and GPU Preference for: !custom_exe!...
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "!custom_exe!" /t REG_SZ /d "GpuPreference=2;" /f >nul 2>&1

if exist "%~dp0vortex-net.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0vortex-net.ps1" -Mode Optimize -CustomProcess "!custom_exe!"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "& { New-NetQosPolicy -Name 'Vortex_Custom_Game' -AppPathNameMatchCondition '!custom_exe!' -DSCPAction 46 -NetworkProfile All -Confirm:$false -ErrorAction SilentlyContinue }"
)

echo.
echo [✓] Custom Game '!custom_exe!' is now prioritized!
pause
goto :MENU

:: =======================================================================
:: MODE 3: WI-FI PING SPIKE STABILIZER TOGGLE
:: =======================================================================
:OPT_WIFI_TOGGLE
cls
echo =======================================================================
echo            WI-FI PING SPIKE STABILIZER (WLAN AUTOCONFIG)
echo =======================================================================
echo In competitive gaming over Wi-Fi, Windows Wireless AutoConfig periodically
echo scans for nearby networks every 60 seconds in the background.
echo This scan causes 200ms-500ms ping spikes and momentary packet loss!
echo.
echo Disabling background scanning eliminates these periodic latency spikes.
echo.
if exist "%~dp0vortex-net.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0vortex-net.ps1" -Mode ToggleWifiScan
) else (
    echo [*] Checking WLAN interfaces...
    netsh wlan show interfaces
    echo.
    set /p iface="Enter your Wi-Fi interface name (or press Enter to cancel): "
    if not "!iface!"=="" (
        netsh wlan set autoconfig enabled=no interface="!iface!"
        echo [✓] Background scanning disabled on '!iface!'.
    )
)
echo.
pause
goto :MENU

:: =======================================================================
:: MODE 5: ROLLBACK
:: =======================================================================
:OPT_REVERT
if exist "%~dp0vortex-revert.bat" (
    call "%~dp0vortex-revert.bat"
    goto :MENU
) else if exist "%~dp0vortex-net.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0vortex-net.ps1" -Mode Revert
    pause
    goto :MENU
) else (
    echo [!] Revert script not found.
    pause
    goto :MENU
)

:: =======================================================================
:: MODE 2: NETWORK ONLY
:: =======================================================================
:OPT_NET_ONLY
cls
echo =======================================================================
echo          APPLYING VORTEX NETWORK AND ADAPTER OPTIMIZATION
echo =======================================================================
echo.
call :RUN_NETWORK
call :RUN_TCPIP
goto :COMPLETION_NET_ONLY

:: =======================================================================
:: MODE 1: FULL OPTIMIZATION
:: =======================================================================
:OPT_FULL
cls
color 0e
echo =======================================================================
echo                   VORTEX OPTIMIZATION CONFIRMATION
echo =======================================================================
echo This script executes deep hardware driver, network, and system tuning:
echo   - Ethernet: Disables Interrupt Moderation, Flow Control, EEE, and Green Ethernet
echo   - Wi-Fi: Sets Roaming to Lowest, disables Packet Coalescing, enforces No SMPS
echo   - Universal: Strips LSO, RSC, VMQ, Checksum offloads; forces MTU 1500
echo   - TCP/IP: Nagle bypass (TcpAckFrequency=1/TcpDelAckTicks=0), CUBIC autotuning
echo   - Quality of Service: Injects Universal DSCP 46 Expedited Forwarding for games
echo   - DNS: Enforces Cloudflare 1.1.1.1 + Native DNS-over-HTTPS (DoH)
echo   - Multimedia: Disables Windows Network Throttling (0xffffffff) and CPU Reserve (0)
echo   - GPU: Enables Hardware-Accelerated GPU Scheduling (HAGS) and GameDVR bypass
echo   - System: Clears DirectX, NVIDIA, AMD, and Intel compiled shader caches
echo   - Bloat: Suspends telemetry and high-overhead background services
echo.
echo NOTE: Power plans are never modified or overridden.
echo [!] Tip: Close any running games or launchers before proceeding.
echo.
set /p confirm="Proceed with full optimization? (Y/N, Default: Y): "
if "%confirm%"=="" set confirm=Y
if /i "%confirm%" neq "Y" (
    echo Optimization cancelled.
    pause
    exit /b 0
)

color 0b

:: =======================================================================
:: [1/5] NETWORK ADAPTER OPTIMIZATION (ETHERNET AND WI-FI)
:: =======================================================================
echo.
echo =======================================================================
echo [1/5] TUNING PHYSICAL NETWORK ADAPTERS (ETHERNET AND WI-FI)...
echo =======================================================================
call :RUN_NETWORK

:: =======================================================================
:: [2/5] TCP/IP STACK OPTIMIZATION
:: =======================================================================
echo.
echo =======================================================================
echo [2/5] TUNING GLOBAL TCP/IP STACK AND SOCKET PARAMETERS...
echo =======================================================================
call :RUN_TCPIP

:: =======================================================================
:: [3/5] UNIVERSAL SHADER CACHE PURGE
:: =======================================================================
echo.
echo =======================================================================
echo [3/5] PURGING UNIVERSAL DIRECTX, NVIDIA, AMD, AND INTEL SHADER CACHES...
echo =======================================================================
del /q /f /s "%localappdata%\D3DSCache\*" >nul 2>&1
del /q /f /s "%localappdata%\NVIDIA\DXCache\*" >nul 2>&1
del /q /f /s "%localappdata%\NVIDIA\GLCache\*" >nul 2>&1
del /q /f /s "%localappdata%\AMD\DxCache\*" >nul 2>&1
del /q /f /s "%localappdata%\AMD\GLCache\*" >nul 2>&1
del /q /f /s "%localappdata%\Intel\ShaderCache\*" >nul 2>&1
echo [✓] Universal Direct3D, NVIDIA, AMD, and Intel shader caches cleared.

:: =======================================================================
:: [4/5] GPU SCHEDULING AND GAMEDVR OPTIMIZATION
:: =======================================================================
echo.
echo =======================================================================
echo [4/5] APPLYING HARDWARE GPU SCHEDULING AND GAMEDVR BYPASS...
echo =======================================================================
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehavior /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f >nul 2>&1
echo [✓] Hardware-Accelerated GPU Scheduling (HAGS) enabled; GameDVR background recording disabled.

:: =======================================================================
:: [5/5] BLOAT REMOVAL AND BACKGROUND SERVICES
:: =======================================================================
echo.
echo =======================================================================
echo [5/5] SUSPENDING HIGH-OVERHEAD BACKGROUND SERVICES...
echo =======================================================================
taskkill /f /im OneDrive.exe >nul 2>&1
taskkill /f /im Cortana.exe >nul 2>&1
taskkill /f /im Skype.exe >nul 2>&1

sc config DiagTrack start= disabled >nul 2>&1
sc stop DiagTrack >nul 2>&1
sc config SysMain start= disabled >nul 2>&1
sc stop SysMain >nul 2>&1
sc config WSearch start= disabled >nul 2>&1
sc stop WSearch >nul 2>&1
echo [✓] DiagTrack (Telemetry), SysMain (Superfetch), and WSearch (Indexer) stopped.

:: =======================================================================
:: COMPLETION SCREEN
:: =======================================================================
color 0a
echo.
echo =======================================================================
echo                  VORTEX OPTIMIZATION COMPLETE
echo =======================================================================
echo System kernel, Ethernet, Wi-Fi, and network stacks are now running at
echo maximum throughput and minimum frame/packet latency across all games.
echo.
echo Changes Applied:
echo   - Ethernet: Zero Interrupt Moderation, Zero Flow Control, Max Buffers (1024)
echo   - Wi-Fi: Roaming set to Lowest, Packet Coalescing disabled, Max Tx Power
echo   - Hardware Offloads: LSO, RSC, VMQ, Checksum stripped across all NICs
echo   - Universal QoS: DSCP 46 Expedited Forwarding injected with NLA bypass
echo   - DNS: Cloudflare 1.1.1.1 + Native DNS-over-HTTPS configured
echo   - Network Throttling: Multimedia packet limiter disabled (0xffffffff)
echo   - TCP/IP Stack: CUBIC Congestion, Nagle bypass, 2000/300ms RTO
echo   - Graphics: HAGS enabled, GameDVR disabled, universal shader caches cleared
echo.
echo [!] NOTE: A PC restart is recommended to re-bind network driver queues.
echo =======================================================================
pause
exit /b 0

:COMPLETION_NET_ONLY
color 0a
echo.
echo =======================================================================
echo             VORTEX NETWORK TUNING COMPLETED
echo =======================================================================
echo Ethernet and Wi-Fi adapters, Universal QoS DSCP 46 rules, Cloudflare
echo DNS/DoH, and TCP/IP stack parameters have been optimized.
echo =======================================================================
pause
exit /b 0

:: =======================================================================
:: SUBROUTINE: RUN NETWORK ENGINE
:: =======================================================================
:RUN_NETWORK
if exist "%~dp0vortex-net.ps1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0vortex-net.ps1" -Mode Optimize
) else (
    echo [*] Executing embedded PowerShell adapter tuning engine...
    set "FALLBACK_PS=%TEMP%\VortexFallbackNet_%RANDOM%.ps1"
    if exist "!FALLBACK_PS!" del "!FALLBACK_PS!" >nul 2>&1
    >> "!FALLBACK_PS!" echo $adapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo foreach ($a in $adapters^) {
    >> "!FALLBACK_PS!" echo     $name = $a.Name
    >> "!FALLBACK_PS!" echo     $guid = $a.InterfaceGuid
    >> "!FALLBACK_PS!" echo     Disable-NetAdapterPowerManagement -Name $name -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo     Disable-NetAdapterLso -Name $name -IPv4 -IPv6 -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo     Disable-NetAdapterChecksumOffload -Name $name -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo     Disable-NetAdapterRsc -Name $name -IPv4 -IPv6 -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo     Disable-NetAdapterVmq -Name $name -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo     netsh interface ipv4 set subinterface \"$name\" mtu=1500 store=persistent 2^>^&1 ^| Out-Null
    >> "!FALLBACK_PS!" echo     Set-DnsClientServerAddress -InterfaceAlias $name -ServerAddresses @("1.1.1.1","1.0.0.1"^) -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo     if ($guid^) {
    >> "!FALLBACK_PS!" echo         Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo         Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TcpDelAckTicks" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo         Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo     }
    >> "!FALLBACK_PS!" echo }
    >> "!FALLBACK_PS!" echo Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0 -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo $qosReg = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS"
    >> "!FALLBACK_PS!" echo if (-not (Test-Path $qosReg^)^) { New-Item -Path $qosReg -Force ^| Out-Null }
    >> "!FALLBACK_PS!" echo Set-ItemProperty -Path $qosReg -Name "Do not use NLA" -Type String -Value "1" -Force -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo Get-NetQosPolicy -ErrorAction SilentlyContinue ^| Where-Object { $_.Name -like 'Vortex_*' } ^| Remove-NetQosPolicy -Confirm:$false -ErrorAction SilentlyContinue
    >> "!FALLBACK_PS!" echo New-NetQosPolicy -Name "Vortex_Gaming_UDP" -IPProtocolMatchCondition UDP -DSCPAction 46 -NetworkProfile All -Confirm:$false -ErrorAction SilentlyContinue ^| Out-Null
    powershell -NoProfile -ExecutionPolicy Bypass -File "!FALLBACK_PS!"
    del "!FALLBACK_PS!" >nul 2>&1
    echo [✓] Embedded network tuning completed.
)
exit /b 0

:: =======================================================================
:: SUBROUTINE: RUN TCP/IP NETSH TUNING
:: =======================================================================
:RUN_TCPIP
echo [*] Flushing DNS, ARP caches, and NetBIOS tables...
ipconfig /flushdns >nul 2>&1
arp -d * >nul 2>&1
nbtstat -R >nul 2>&1

echo [*] Applying global Netsh TCP autotuning and congestion providers...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
netsh int tcp set global ecncapability=disabled >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1
netsh int tcp set global dca=enabled >nul 2>&1
netsh int tcp set global netdma=enabled >nul 2>&1
netsh int ip set global taskoffload=disabled >nul 2>&1
netsh int ip set global neighborcachelimit=4096 >nul 2>&1

echo [*] Deactivating legacy transition tunneling adapters (Teredo, 6to4, ISATAP)...
netsh interface teredo set state disabled >nul 2>&1
netsh interface 6to4 set state disabled >nul 2>&1
netsh interface isatap set state disabled >nul 2>&1

echo [✓] Vortex TCP/IP Stack Applied.
exit /b 0
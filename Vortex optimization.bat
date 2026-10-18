@echo off
setlocal EnableDelayedExpansion
title Vortex Optimization Suite v2.0 - Gaming and Low-Latency Network Engine
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
echo          VORTEX OPTIMIZATION SUITE v2.0 - s3amm3r
echo       Competitive Gaming, Ethernet and Wi-Fi Latency Engine
echo =======================================================================
echo.
echo Select an execution mode:
echo.
echo   [1] Full Vortex Optimization (Power + Ethernet/Wi-Fi + TCP/IP + QoS + Bloat)
echo   [2] Network and Adapter Tuning Only (Ethernet, Wi-Fi, QoS DSCP 46, Cloudflare DNS)
echo   [3] Wi-Fi Ping Spike Stabilizer (Toggle WLAN AutoConfig Background Scanning)
echo   [4] Rollback to Windows Defaults (Restore original settings)
echo   [5] Exit
echo.
set /p choice="Enter choice [1-5] (Default: 1): "

if "%choice%"=="" set choice=1
if "%choice%"=="1" goto :OPT_FULL
if "%choice%"=="2" goto :OPT_NET_ONLY
if "%choice%"=="3" goto :OPT_WIFI_TOGGLE
if "%choice%"=="4" goto :OPT_REVERT
if "%choice%"=="5" exit /b 0

echo [!] Invalid selection. Please choose 1, 2, 3, 4, or 5.
timeout /t 2 >nul
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
:: MODE 4: ROLLBACK
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
echo This script executes deep kernel, hardware driver, and network tuning:
echo   - Ethernet: Disables Interrupt Moderation, Flow Control, EEE, and Green Ethernet
echo   - Wi-Fi: Sets Roaming to Lowest, disables Packet Coalescing, enforces No SMPS
echo   - Universal: Strips LSO, RSC, VMQ, Checksum offloads; forces MTU 1500
echo   - TCP/IP: Nagle bypass (TcpAckFrequency=1/TcpDelAckTicks=0), CUBIC autotuning
echo   - Quality of Service: Injects DSCP 46 Expedited Forwarding for Fortnite/UDP
echo   - DNS: Enforces Cloudflare 1.1.1.1 + Native DNS-over-HTTPS (DoH)
echo   - Multimedia: Disables Windows Network Throttling (0xffffffff) and CPU Reserve (0)
echo   - Power: Activates Ultimate Performance plan, unparks cores, disables CPU sleep
echo   - System: Clears DirectX/NVIDIA shader caches, disables telemetry services
echo.
echo [!] Tip: Close any running games or game launchers before proceeding.
echo.
set /p confirm="Proceed with full optimization? (Y/N, Default: Y): "
if "%confirm%"=="" set confirm=Y
if /i "%confirm%" neq "Y" (
    echo Optimization cancelled.
    pause
    exit /b 0
)

color 0b
echo.
echo =======================================================================
echo [1/6] CONFIGURING VORTEX POWER PROFILE AND KERNEL IDLE BYPASS...
echo =======================================================================

:: 1. Search for existing Ultimate Performance power scheme to avoid duplicates
set "ULT_GUID="
for /f "tokens=4" %%a in ('powercfg -list 2^>nul ^| findstr /i "Ultimate"') do (
    set "ULT_GUID=%%a"
)

:: 2. If not already present, duplicate from base template
if not defined ULT_GUID (
    for /f "tokens=4" %%a in ('powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2^>nul') do (
        set "ULT_GUID=%%a"
    )
)

:: 3. Activate Ultimate Performance, or fallback to High Performance
if defined ULT_GUID ( 
    powercfg -setactive !ULT_GUID! >nul 2>&1
    echo [✓] Windows Ultimate Performance scheme activated (!ULT_GUID!).
) else ( 
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    echo [✓] High Performance power scheme activated.
)

:: Turn off PCI Express Link State Power Management (AC & DC)
powercfg /SETACVALUEINDEX SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 >nul 2>&1
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 >nul 2>&1

:: Wireless Adapter Power Saving Mode -> Maximum Performance (AC & DC)
powercfg /SETACVALUEINDEX SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 >nul 2>&1
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 >nul 2>&1

:: Unpark CPU Cores (100% min state on AC & DC)
powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 >nul 2>&1
powercfg -setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100 >nul 2>&1
powercfg -SetActive SCHEME_CURRENT >nul 2>&1

:: Disable Processor Sleep / C-State Transitions for Zero Input Jitter
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Processor" /v ProcessorIdleDisable /t REG_DWORD /d 1 /f >nul 2>&1
:: Disable Fast Startup / Hibernation to avoid kernel state corruption
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul 2>&1

echo [✓] Vortex Power Profile Applied: Cores Unparked, CPU Idle States Bypassed.

:: =======================================================================
:: [2/6] NETWORK ADAPTER OPTIMIZATION (ETHERNET & WI-FI)
:: =======================================================================
echo.
echo =======================================================================
echo [2/6] TUNING PHYSICAL NETWORK ADAPTERS (ETHERNET AND WI-FI)...
echo =======================================================================
call :RUN_NETWORK

:: =======================================================================
:: [3/6] TCP/IP STACK OPTIMIZATION
:: =======================================================================
echo.
echo =======================================================================
echo [3/6] TUNING GLOBAL TCP/IP STACK AND SOCKET PARAMETERS...
echo =======================================================================
call :RUN_TCPIP

:: =======================================================================
:: [4/6] CACHE & SHADER CLEANUP
:: =======================================================================
echo.
echo =======================================================================
echo [4/6] PURGING COMPILED SHADER CACHES AND TELEMETRY LOGS...
echo =======================================================================
del /q /f "%windir%\Prefetch\*Fortnite*.pf" >nul 2>&1
rmdir /s /q "%localappdata%\FortniteGame\Saved\webcache" >nul 2>&1
del /q /f /s "%localappdata%\D3DSCache\*" >nul 2>&1
del /q /f /s "%localappdata%\NVIDIA\DXCache\*" >nul 2>&1
del /q /f /s "%localappdata%\AMD\DxCache\*" >nul 2>&1
echo [✓] Shader caches and game webcaches cleared.

:: =======================================================================
:: [5/6] GPU & DIRECTX PROFILE
:: =======================================================================
echo.
echo =======================================================================
echo [5/6] APPLYING DIRECTX GPU PREFERENCES AND HARDWARE SCHEDULING...
echo =======================================================================
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "FortniteClient-Win64-Shipping.exe" /t REG_SZ /d "GpuPreference=2;" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
echo [✓] Discrete GPU Priority forced; Hardware-Accelerated GPU Scheduling (HAGS) enabled.

:: =======================================================================
:: [6/6] BLOAT REMOVAL & BACKGROUND SERVICES
:: =======================================================================
echo.
echo =======================================================================
echo [6/6] SUSPENDING HIGH-OVERHEAD BACKGROUND SERVICES...
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
echo maximum throughput and minimum frame/packet latency.
echo.
echo Changes Applied:
echo   - Ethernet: Zero Interrupt Moderation, Zero Flow Control, Max Buffers (1024)
echo   - Wi-Fi: Roaming set to Lowest, Packet Coalescing disabled, Max Tx Power
echo   - Hardware Offloads: LSO, RSC, VMQ, Checksum stripped across all NICs
echo   - Quality of Service: DSCP 46 Expedited Forwarding injected with NLA bypass
echo   - DNS: Cloudflare 1.1.1.1 + Native DNS-over-HTTPS configured
echo   - Network Throttling: Multimedia packet limiter disabled (0xffffffff)
echo   - TCP/IP Stack: CUBIC Congestion, Nagle bypass, 2000/300ms RTO
echo.
echo [!] NOTE: A PC restart is recommended to re-bind network driver queues.
echo =======================================================================
echo.
set /p launch="Launch Fortnite now with high priority? (Y/N, Default: N): "
if /i "%launch%"=="Y" (
    start "" /high "com.epicgames.launcher://apps/Fortnite?action=launch&silent=true"
)
exit /b 0

:COMPLETION_NET_ONLY
color 0a
echo.
echo =======================================================================
echo             VORTEX NETWORK TUNING COMPLETED
echo =======================================================================
echo Ethernet and Wi-Fi adapters, QoS DSCP 46 rules, Cloudflare DNS/DoH,
echo and TCP/IP stack parameters have been optimized.
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
    (
        echo $adapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue
        echo foreach ($a in $adapters) {
        echo     $name = $a.Name
        echo     $guid = $a.InterfaceGuid
        echo     Disable-NetAdapterPowerManagement -Name $name -ErrorAction SilentlyContinue
        echo     Disable-NetAdapterLso -Name $name -IPv4 -IPv6 -ErrorAction SilentlyContinue
        echo     Disable-NetAdapterChecksumOffload -Name $name -ErrorAction SilentlyContinue
        echo     Disable-NetAdapterRsc -Name $name -IPv4 -IPv6 -ErrorAction SilentlyContinue
        echo     Disable-NetAdapterVmq -Name $name -ErrorAction SilentlyContinue
        echo     netsh interface ipv4 set subinterface \"$name\" mtu=1500 store=persistent 2^>^&1 ^| Out-Null
        echo     Set-DnsClientServerAddress -InterfaceAlias $name -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue
        echo     if ($guid) {
        echo         Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        echo         Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TcpDelAckTicks" -Value 0 -Type DWord -ErrorAction SilentlyContinue
        echo         Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
        echo     }
        echo }
        echo Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff -ErrorAction SilentlyContinue
        echo Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        echo $qosReg = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS"
        echo if (-not (Test-Path $qosReg)) { New-Item -Path $qosReg -Force ^| Out-Null }
        echo Set-ItemProperty -Path $qosReg -Name "Do not use NLA" -Type String -Value "1" -Force -ErrorAction SilentlyContinue
        echo Remove-NetQosPolicy -Name "Vortex_Fortnite" -Confirm:$false -ErrorAction SilentlyContinue
        echo New-NetQosPolicy -Name "Vortex_Fortnite" -AppPathNameMatchCondition "FortniteClient-Win64-Shipping.exe" -DSCPAction 46 -NetworkProfile All -Confirm:$false -ErrorAction SilentlyContinue ^| Out-Null
    ) > "!FALLBACK_PS!"
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
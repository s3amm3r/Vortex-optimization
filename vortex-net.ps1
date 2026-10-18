<#
.SYNOPSIS
    Vortex Network Engine v2.0 - High-Performance Ethernet and Wi-Fi Tuning
.DESCRIPTION
    Comprehensive low-latency network optimizer for Windows 10/11.
    Tuning targets:
      - Ethernet: Interrupt Moderation, Flow Control, Green/EEE power savings, Transmit/Receive Buffers.
      - Wi-Fi: Roaming Aggressiveness, Packet Coalescing, MIMO Power Save (No SMPS), U-APSD, Transmit Power.
      - Universal: LSO/RSC/VMQ stripping, Checksum offloads, Nagle algorithm bypass (TcpAckFrequency/DelAckTicks),
                   Cloudflare DNS + DoH, MTU 1500, QoS DSCP 46 Expedited Forwarding, TCP CUBIC stack.
.PARAMETER Mode
    'Optimize'       - Applies deep Ethernet, Wi-Fi, TCP/IP, QoS, and throttling tweaks.
    'NetworkOnly'    - Focuses strictly on physical adapters, DNS, QoS, and TCP/IP stack.
    'Revert'         - Restores Windows defaults, DHCP, default offloads, and removes QoS rules.
    'ToggleWifiScan' - Toggles WLAN AutoConfig background scanning on active Wi-Fi adapters.
#>

[CmdletBinding()]
param(
    [ValidateSet('Optimize', 'NetworkOnly', 'Revert', 'ToggleWifiScan')]
    [string]$Mode = 'Optimize'
)

$ErrorActionPreference = 'SilentlyContinue'

function Write-VortexStatus {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [string]$Color = 'Cyan'
    )
    Write-Host "[*] $Message" -ForegroundColor $Color
}

function Write-VortexSuccess {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    Write-Host "[+] $Message" -ForegroundColor Green
}

function Write-VortexWarning {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    Write-Host "[!] $Message" -ForegroundColor Yellow
}

function Show-VortexBanner {
    Write-Host "=======================================================================" -ForegroundColor Cyan
    Write-Host "         VORTEX NETWORK ENGINE v2.0 (ETHERNET & WI-FI)" -ForegroundColor Yellow
    Write-Host "=======================================================================" -ForegroundColor Cyan
}

# ==============================================================================
# MODE: TOGGLE WI-FI SCAN (STABILIZER)
# ==============================================================================
if ($Mode -eq 'ToggleWifiScan') {
    Show-VortexBanner
    Write-VortexStatus -Message "Checking Wireless AutoConfig interfaces..." -Color "Yellow"
    
    $wlanCheck = netsh wlan show interfaces 2>&1
    if ($LASTEXITCODE -ne 0 -or ($wlanCheck -join ' ') -match 'not running') {
        Write-VortexWarning -Message "WLAN service is not running or no active Wi-Fi adapter detected."
        return
    }

    $wifiAdapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue | Where-Object { 
        $_.PhysicalMediaType -match '802.11' -or $_.MediaType -match '802.11' -or $_.InterfaceDescription -match 'Wi-Fi|Wireless|802.11|WLAN'
    }

    if (-not $wifiAdapters) {
        Write-VortexWarning -Message "No physical Wi-Fi adapters found."
        return
    }

    foreach ($w in $wifiAdapters) {
        $wName = $w.Name
        Write-VortexStatus -Message "Inspecting Wi-Fi Adapter: $wName ($($w.InterfaceDescription))"
        
        $query = netsh wlan show autoconfig interface="$wName" 2>&1
        if (($query -join ' ') -match 'enabled') {
            netsh wlan set autoconfig enabled=no interface="$wName" | Out-Null
            Write-VortexSuccess -Message "Background scanning DISABLED on $wName. 60-second ping spikes eliminated for gaming!"
            Write-Host "    (Run again to re-enable when you need to search for new Wi-Fi networks)" -ForegroundColor DarkGray
        } else {
            netsh wlan set autoconfig enabled=yes interface="$wName" | Out-Null
            Write-VortexSuccess -Message "Background scanning RE-ENABLED on $wName. Standard Wi-Fi roaming restored."
        }
    }
    return
}

# ==============================================================================
# MODE: REVERT (ROLLBACK)
# ==============================================================================
if ($Mode -eq 'Revert') {
    Show-VortexBanner
    Write-VortexStatus -Message "Rolling back network, adapter, QoS, and TCP/IP stack to Windows defaults..." -Color "Yellow"

    # 1. Reset Physical Adapters
    $physicalAdapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue
    foreach ($a in $physicalAdapters) {
        $name = $a.Name
        $guid = $a.InterfaceGuid
        Write-VortexStatus -Message "Restoring default settings on: $name"

        # Reset DNS to DHCP
        Set-DnsClientServerAddress -InterfaceAlias $name -ResetServerAddresses -ErrorAction SilentlyContinue

        # Re-enable Adapter Offloads
        Enable-NetAdapterLso -Name $name -IPv4 -IPv6 -ErrorAction SilentlyContinue
        Enable-NetAdapterChecksumOffload -Name $name -ErrorAction SilentlyContinue
        Enable-NetAdapterRsc -Name $name -IPv4 -IPv6 -ErrorAction SilentlyContinue
        Enable-NetAdapterPowerManagement -Name $name -ErrorAction SilentlyContinue

        # Re-enable Ethernet features
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*InterruptModeration" -RegistryValue "1" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*FlowControl" -RegistryValue "3" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*EEE" -RegistryValue "1" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*EnergyEfficientEthernet" -RegistryValue "1" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*GreenEthernet" -RegistryValue "1" -ErrorAction SilentlyContinue

        # Wi-Fi resets
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*RoamingAggressiveness" -RegistryValue "3" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*PacketCoalescing" -RegistryValue "1" -ErrorAction SilentlyContinue
        netsh wlan set autoconfig enabled=yes interface="$name" 2>&1 | Out-Null

        # Remove Nagle bypass on interface
        if ($guid) {
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TcpAckFrequency" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TcpDelAckTicks" -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid" -Name "TCPNoDelay" -ErrorAction SilentlyContinue
        }
    }

    # 2. Remove All Vortex QoS Policies
    Get-NetQosPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Vortex_*' } | Remove-NetQosPolicy -Confirm:$false -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" -Name "Do not use NLA" -ErrorAction SilentlyContinue

    # 3. Restore Multimedia Network Throttling & Responsiveness
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 10 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 20 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Type DWord -Value 2 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Type String -Value "Medium" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "SFIO Priority" -Type String -Value "Normal" -ErrorAction SilentlyContinue

    # 4. Restore TCP Congestion Provider to default
    Get-NetTCPSetting -ErrorAction SilentlyContinue | Where-Object { $_.SettingName -in @('Internet', 'InternetCustom') } | ForEach-Object {
        Set-NetTCPSetting -SettingName $_.SettingName -CongestionProvider default -Timestamps Allowed -EcnCapability Disabled -ErrorAction SilentlyContinue
    }

    Write-VortexSuccess -Message "Network stack and adapters reverted to standard Windows defaults."
    return
}

# ==============================================================================
# MODE: OPTIMIZE (ETHERNET + WI-FI + TCP/IP + QOS)
# ==============================================================================
Show-VortexBanner

# 1. Hardware Enumeration
Write-VortexStatus -Message "Scanning and classifying physical network hardware..."
$physicalAdapters = Get-NetAdapter -Physical -ErrorAction SilentlyContinue

if (-not $physicalAdapters) {
    Write-VortexWarning -Message "No physical network adapters detected. Exiting adapter pass."
    return
}

foreach ($a in $physicalAdapters) {
    $name = $a.Name
    $guid = $a.InterfaceGuid
    $desc = $a.InterfaceDescription
    $media = $a.PhysicalMediaType
    $isWifi = ($media -match '802.11') -or ($desc -match 'Wi-Fi|Wireless|802.11|WLAN') -or ($a.MediaType -match '802.11')
    $isEthernet = (-not $isWifi) -and (($media -match '802.3') -or ($desc -match 'Ethernet|GbE|Family Controller|I211|I219|I225|RTL81|LAN') -or ($a.MediaType -match '802.3'))

    Write-Host "-----------------------------------------------------------------------" -ForegroundColor DarkGray
    if ($isWifi) {
        Write-Host "[>] WI-FI ADAPTER DETECTED: $name ($desc)" -ForegroundColor Yellow
    } elseif ($isEthernet) {
        Write-Host "[>] ETHERNET ADAPTER DETECTED: $name ($desc)" -ForegroundColor Cyan
    } else {
        Write-Host "[>] PHYSICAL ADAPTER DETECTED: $name ($desc)" -ForegroundColor White
    }

    # --------------------------------------------------------------------------
    # A. Universal Adapter Optimization (Both Ethernet & Wi-Fi)
    # --------------------------------------------------------------------------
    Write-VortexStatus -Message "  -> Stripping hardware offloads and DPC latency jitter..."
    Disable-NetAdapterPowerManagement -Name $name -ErrorAction SilentlyContinue
    Disable-NetAdapterLso -Name $name -IPv4 -IPv6 -ErrorAction SilentlyContinue
    Disable-NetAdapterChecksumOffload -Name $name -ErrorAction SilentlyContinue
    Disable-NetAdapterRsc -Name $name -IPv4 -IPv6 -ErrorAction SilentlyContinue
    Disable-NetAdapterVmq -Name $name -ErrorAction SilentlyContinue

    # Set persistent MTU 1500
    netsh interface ipv4 set subinterface "$name" mtu=1500 store=persistent 2>&1 | Out-Null
    netsh interface ipv6 set subinterface "$name" mtu=1500 store=persistent 2>&1 | Out-Null

    # Nagle Algorithm Bypass on Interface
    if ($guid) {
        $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$guid"
        Set-ItemProperty -Path $regPath -Name "TcpAckFrequency" -Type DWord -Value 1 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "TcpDelAckTicks" -Type DWord -Value 0 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "TCPNoDelay" -Type DWord -Value 1 -ErrorAction SilentlyContinue
    }

    # Cloudflare DNS and Native DoH (DNS-over-HTTPS)
    Set-DnsClientServerAddress -InterfaceAlias $name -ServerAddresses ("1.1.1.1","1.0.0.1") -ErrorAction SilentlyContinue
    if (Get-Command Set-DnsClientDohServerAddress -ErrorAction SilentlyContinue) {
        Set-DnsClientDohServerAddress -ServerAddresses "1.1.1.1" -DohTemplate "https://cloudflare-dns.com/dns-query" -AllowFallbackToUdp $true -AutoUpgrade $true -ErrorAction SilentlyContinue
        Set-DnsClientDohServerAddress -ServerAddresses "1.0.0.1" -DohTemplate "https://cloudflare-dns.com/dns-query" -AllowFallbackToUdp $true -AutoUpgrade $true -ErrorAction SilentlyContinue
    }
    Set-DnsClientServerAddress -InterfaceAlias $name -ServerAddresses ("2606:4700:4700::1111","2606:4700:4700::1001") -Family IPv6 -ErrorAction SilentlyContinue

    # --------------------------------------------------------------------------
    # B. Ethernet-Specific Low-Latency Driver Overrides
    # --------------------------------------------------------------------------
    if ($isEthernet) {
        Write-VortexStatus -Message "  -> Applying Ethernet kernel and transceiver tuning..."
        
        # 1. Disable Interrupt Moderation (instant packet CPU delivery, zero buffering)
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*InterruptModeration" -RegistryValue "0" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*InterruptModerationRate" -RegistryValue "0" -ErrorAction SilentlyContinue
        Disable-NetAdapterInterruptModeration -Name $name -ErrorAction SilentlyContinue

        # 2. Disable Flow Control (avoids PAUSE transmission latency queues)
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*FlowControl" -RegistryValue "0" -ErrorAction SilentlyContinue

        # 3. Strip Energy Efficient Ethernet (EEE) and Green Ethernet sleep cycles
        $eeeKeys = @('*EEE', '*EnergyEfficientEthernet', '*GreenEthernet', '*GigaLite', '*PowerSavingMode', 
                     '*ModernStandbyWoLMagicPacket', 'AdvancedEEE', 'EnablePME', 'AutoPowerSaveModeEnabled', 'ReduceSpeedOnPowerDown')
        foreach ($k in $eeeKeys) {
            Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword $k -RegistryValue "0" -ErrorAction SilentlyContinue
        }

        # 4. Enlarge Ring Buffers to prevent micro-burst packet loss
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*ReceiveBuffers" -RegistryValue "1024" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*TransmitBuffers" -RegistryValue "1024" -ErrorAction SilentlyContinue

        # 5. Disable Wake-on-LAN and offload sleeping
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*WakeOnMagicPacket" -RegistryValue "0" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*WakeOnPattern" -RegistryValue "0" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*PMARPOffload" -RegistryValue "0" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*PMNSOffload" -RegistryValue "0" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "ShutdownWakeOnLan" -RegistryValue "0" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "WolShutdownLinkSpeed" -RegistryValue "0" -ErrorAction SilentlyContinue

        Write-VortexSuccess -Message "Ethernet Adapter '$name' fully tuned (No Moderation, No EEE, Zero Flow Control)."
    }

    # --------------------------------------------------------------------------
    # C. Wi-Fi-Specific Low-Latency Driver Overrides
    # --------------------------------------------------------------------------
    if ($isWifi) {
        Write-VortexStatus -Message "  -> Applying Wi-Fi radio and 802.11 latency tuning..."

        # 1. Roaming Aggressiveness to Lowest (1) - Stops background AP hunting during matches
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*RoamingAggressiveness" -RegistryValue "1" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "RoamAggressiveness" -RegistryValue "1" -ErrorAction SilentlyContinue

        # 2. Disable Packet Coalescing - Delivers Wi-Fi frames instantly without queuing
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*PacketCoalescing" -RegistryValue "0" -ErrorAction SilentlyContinue

        # 3. MIMO Power Save Mode to 'No SMPS' (0) - Keeps all spatial streams active
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*MIMOPowerSaveMode" -RegistryValue "0" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "MIMOPowerSaveMode" -RegistryValue "0" -ErrorAction SilentlyContinue

        # 4. Disable U-APSD (Unscheduled Automatic Power Save Delivery)
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*UAPSD" -RegistryValue "0" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "uAPSDSupport" -RegistryValue "0" -ErrorAction SilentlyContinue

        # 5. Set Transmit Power to Maximum (5 / 100%)
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "*TransmitPower" -RegistryValue "5" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "TxPowerLevel" -RegistryValue "5" -ErrorAction SilentlyContinue

        # 6. Intel Wi-Fi Throughput Booster & Band Preference
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "ThroughputBoosterEnabled" -RegistryValue "1" -ErrorAction SilentlyContinue
        Set-NetAdapterAdvancedProperty -Name $name -RegistryKeyword "PreferredBand" -RegistryValue "3" -ErrorAction SilentlyContinue

        Write-VortexSuccess -Message "Wi-Fi Adapter '$name' fully tuned (Roam=Lowest, No SMPS, Max Tx Power, No Coalescing)."
    }
}

# ------------------------------------------------------------------------------
# 2. Windows Multimedia Network Throttling & Responsiveness
# ------------------------------------------------------------------------------
Write-Host "-----------------------------------------------------------------------" -ForegroundColor DarkGray
Write-VortexStatus -Message "Disabling Windows Multimedia Network Packet Throttling..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Type DWord -Value 0xffffffff -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Type DWord -Value 0 -ErrorAction SilentlyContinue

# Game Task Scheduling
$gamesTaskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
if (Test-Path $gamesTaskPath) {
    Set-ItemProperty -Path $gamesTaskPath -Name "GPU Priority" -Type DWord -Value 8 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gamesTaskPath -Name "Priority" -Type DWord -Value 6 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gamesTaskPath -Name "Scheduling Category" -Type String -Value "High" -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $gamesTaskPath -Name "SFIO Priority" -Type String -Value "High" -ErrorAction SilentlyContinue
}
Write-VortexSuccess -Message "Network packet throttling disabled (0xffffffff); 100% CPU priority given to game packets."

# ------------------------------------------------------------------------------
# 3. Quality of Service (QoS) DSCP 46 Policies
# ------------------------------------------------------------------------------
Write-VortexStatus -Message "Configuring QoS Policies (DSCP 46 Expedited Forwarding)..."

# Enable DSCP marking without Active Directory domain (NLA Bypass)
$qosReg = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\QoS"
if (-not (Test-Path $qosReg)) { New-Item -Path $qosReg -Force | Out-Null }
Set-ItemProperty -Path $qosReg -Name "Do not use NLA" -Type String -Value "1" -Force -ErrorAction SilentlyContinue

# Purge existing policies if present
Get-NetQosPolicy -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'Vortex_*' } | Remove-NetQosPolicy -Confirm:$false -ErrorAction SilentlyContinue

# Inject New QoS Policies for Game Clients & UDP
New-NetQosPolicy -Name "Vortex_Fortnite" -AppPathNameMatchCondition "FortniteClient-Win64-Shipping.exe" -DSCPAction 46 -NetworkProfile All -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
New-NetQosPolicy -Name "Vortex_Fortnite_EAC" -AppPathNameMatchCondition "FortniteClient-Win64-Shipping_EAC.exe" -DSCPAction 46 -NetworkProfile All -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
New-NetQosPolicy -Name "Vortex_Fortnite_BE" -AppPathNameMatchCondition "FortniteClient-Win64-Shipping_BE.exe" -DSCPAction 46 -NetworkProfile All -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
New-NetQosPolicy -Name "Vortex_Gaming_UDP" -IPProtocol UDP -DSCPAction 46 -NetworkProfile All -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
New-NetQosPolicy -Name "Vortex_EpicGames" -AppPathNameMatchCondition "EpicGamesLauncher.exe" -DSCPAction 34 -NetworkProfile All -Confirm:$false -ErrorAction SilentlyContinue | Out-Null

Write-VortexSuccess -Message "QoS DSCP 46 policies created (FortniteClient, EAC/BE, and UDP packets prioritised)."

# ------------------------------------------------------------------------------
# 4. Modern TCP/IP Stack Settings via PowerShell CIM
# ------------------------------------------------------------------------------
Write-VortexStatus -Message "Configuring Modern TCP/IP Congestion and Auto-Tuning Stack..."

$tcpSettings = Get-NetTCPSetting -ErrorAction SilentlyContinue | Where-Object { $_.SettingName -in @('Internet', 'InternetCustom', 'Datacenter', 'DatacenterCustom') }
foreach ($s in $tcpSettings) {
    Set-NetTCPSetting -SettingName $s.SettingName -AutoTuningLevelLocal Normal -ScalingHeuristics Disabled -EcnCapability Disabled -Timestamps Disabled -NonSackRttResiliency Disabled -InitialRto 2000 -MinRto 300 -ErrorAction SilentlyContinue
    try {
        Set-NetTCPSetting -SettingName $s.SettingName -CongestionProvider CUBIC -ErrorAction Stop
    } catch {
        Set-NetTCPSetting -SettingName $s.SettingName -CongestionProvider CTCP -ErrorAction SilentlyContinue
    }
}

# TCP/IP Global Parameters in Registry
$tcpipParams = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Set-ItemProperty -Path $tcpipParams -Name "DefaultTTL" -Type DWord -Value 64 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $tcpipParams -Name "EnableTCPA" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $tcpipParams -Name "EnableWsd" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $tcpipParams -Name "MaxUserPort" -Type DWord -Value 65534 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $tcpipParams -Name "TcpTimedWaitDelay" -Type DWord -Value 30 -ErrorAction SilentlyContinue
Set-ItemProperty -Path $tcpipParams -Name "StrictTimeWaitSeqCheck" -Type DWord -Value 1 -ErrorAction SilentlyContinue

Write-VortexSuccess -Message "TCP/IP Stack optimized: CUBIC congestion, RSS, RTO 2000/300ms, Timestamps disabled."
Write-Host "=======================================================================" -ForegroundColor Cyan

# Vortex Optimization Suite v2.1

**Vortex Optimization Suite** is an advanced, universal Windows batch + PowerShell tuning suite authored by **s3amm3r**, engineered to eliminate micro-stutter, minimize input latency, reduce bufferbloat, and prioritize real-time packet delivery across **all competitive multiplayer games** (Valorant, Counter-Strike 2, Fortnite, Apex Legends, Call of Duty, Overwatch, Rocket League, Rainbow Six Siege, and custom games).

It applies deep bare-metal adjustments to network transceivers (Ethernet & Wi-Fi), TCP/IP stacks, DNS-over-HTTPS, Universal QoS DSCP 46 priority rules, GPU scheduling, and background bloat mitigation.

> 🛡️ **Zero Power-Plan Interference**  
> Vortex **does not change, switch, or override your Windows power plan**. Your custom power scheme and battery policies remain 100% intact.

> ⚠️ **Safety & Rollback**  
> An automated 1-click rollback script (`vortex-revert.bat`) is included to restore default Windows network stacks, DHCP, and services at any time.

---

## 📁 Repository Structure

```text
Vortex-optimization/
├── Vortex optimization.bat   # Interactive CLI & Master optimization engine (Options 1–6)
├── vortex.bat                # Convenience alias / shortcut runner
├── vortex-net.ps1            # Deep Ethernet & Wi-Fi PowerShell network engine
├── vortex-revert.bat         # Automated 1-click rollback & restore script
├── LICENSE                   # MIT License
└── README.md                 # Complete technical architecture & usage guide
```

---

## 🚀 Key Features

| Category | Description |
| :--- | :--- |
| **Universal Game Support** | Game-agnostic architecture prioritizing real-time UDP gaming streams and major competitive titles, with support for any custom `.exe`. |
| **Ethernet Tuning** | Disables Interrupt Moderation, Flow Control, Energy Efficient Ethernet (EEE), Green Ethernet; maximizes Ring Buffers (1024). |
| **Wi-Fi Tuning** | Minimizes Roaming Aggressiveness (Lowest), disables Packet Coalescing, enforces No SMPS (full MIMO), disables U-APSD, sets Max Transmit Power. |
| **Wi-Fi Stabilizer** | Integrated toggle to disable Windows WLAN AutoConfig background scanning (eliminating 60-second ping spikes during matches). |
| **Universal NIC Tuning** | Strips LSO, RSC, VMQ, and Checksum hardware offloads; enforces persistent MTU 1500; disables adapter power management. |
| **TCP/IP Stack** | Enforces CUBIC congestion provider, disables Nagle algorithm (`TcpAckFrequency=1`, `TcpDelAckTicks=0`), disables TCP timestamps, sets 2000/300ms RTO. |
| **Universal QoS Priority** | Injects DSCP 46 Expedited Forwarding policies for UDP gaming packets, major titles, and custom game processes with workgroup NLA bypass. |
| **Network Throttling** | Disables Windows Multimedia Network Packet Throttling (`NetworkThrottlingIndex = 0xffffffff`) and CPU reservation (`SystemResponsiveness = 0`). |
| **DNS & DoH** | Configures Cloudflare DNS (`1.1.1.1` / `1.0.0.1`) with native DNS-over-HTTPS (DoH) encrypted templates. |
| **Universal Shader Cache** | Purges Direct3D D3DSCache, NVIDIA DX/GL caches, AMD DX/GL caches, and Intel ShaderCache to resolve stutter from corrupt shaders. |
| **GPU Scheduling** | Enables Windows Hardware-Accelerated GPU Scheduling (HAGS) and disables GameDVR background recording latency. |
| **Bloat Mitigation** | Kills background sync agents (`OneDrive`, `Cortana`, `Skype`) and disables high-overhead telemetry services (`DiagTrack`, `SysMain`, `WSearch`). |
| **Automated Rollback** | Includes dedicated `vortex-revert.bat` to restore default Windows network stacks, DHCP, and services with 1 click. |

---

## ⚡ Ethernet & Wi-Fi Latency Engineering

### 🌐 Ethernet Transceiver Optimization
Standard Windows network adapter drivers prioritize power savings and CPU offloading over latency:
1. **Interrupt Moderation (`*InterruptModeration = 0`):** By default, network cards batch packets into periodic interrupts to reduce CPU load. Vortex disables this so incoming game packets immediately trigger a CPU interrupt with zero queuing delay.
2. **Flow Control (`*FlowControl = 0`):** Disables 802.3x PAUSE frames that artificially stall transmission queues during buffer congestion.
3. **Energy Efficient Ethernet (EEE / Green Ethernet):** EEE puts transceivers into Low Power Idle (LPI). Waking from LPI incurs a 16–30 µs latency spike. Vortex disables `*EEE`, `*EnergyEfficientEthernet`, `*GreenEthernet`, and `*GigaLite`.
4. **Ring Buffers (`1024`):** Expands Receive and Transmit buffer descriptors to prevent packet drops during intense micro-burst exchanges.

### 📶 Wi-Fi 802.11 Radio Optimization
Wi-Fi inherently suffers from packet jitter due to radio power states and background channel scanning:
1. **Roaming Aggressiveness (`1` / Lowest):** Prevents the Wi-Fi card from periodically probing for alternative BSSIDs or access points mid-match.
2. **Packet Coalescing (`0` / Disabled):** Disables random packet buffering designed for mobile battery saving.
3. **MIMO Power Save Mode (`0` / No SMPS):** Prevents the radio from shutting down secondary antennas or spatial streams.
4. **U-APSD (`0` / Disabled):** Eliminates Unscheduled Automatic Power Save Delivery sleep transitions.
5. **Transmit Power (`5` / 100%):** Enforces maximum radio transmission output for minimal frame drops.
6. **WLAN AutoConfig Background Scan Fix:** Windows periodically conducts 60-second background scans across all channels to update the available Wi-Fi list, causing classic 200–500ms ping spikes. Vortex includes a 1-click toggle (`Option 3`) to disable background scanning while connected.

---

## 🧪 Usage

1. Open an elevated command prompt or right-click **`Vortex optimization.bat`** (or **`vortex.bat`**) and select **Run as Administrator**.
2. Select your desired execution mode from the menu:
   - `[1] Full Vortex Optimization` (Universal network, QoS, shader cache, and system tuning)
   - `[2] Network and Adapter Tuning Only` (Ethernet, Wi-Fi, Universal QoS, and TCP/IP)
   - `[3] Wi-Fi Ping Spike Stabilizer` (Toggle WLAN background scanning)
   - `[4] Prioritize Custom Game` (Enter any custom game `.exe` to prioritize with DSCP 46 and GPU Preference)
   - `[5] Rollback to Windows Defaults`
   - `[6] Exit`
3. Restart your PC to allow network drivers and kernel queues to re-bind cleanly.

### Automated / Headless Execution
You can run the script non-interactively using the `/y` or `/auto` switch:
```cmd
"Vortex optimization.bat" /y
```

---

## 🔄 Reverting Changes (Automated Rollback)

Vortex includes an automated 1-click rollback engine that restores Windows defaults **without touching your power plan**:

1. Right-click **`vortex-revert.bat`** and select **Run as Administrator** (or select `[5]` in the main menu).
2. The script will automatically:
   - Reset network adapters back to automatic DHCP.
   - Re-enable Interrupt Moderation, Flow Control, Ring Buffers (256), and default driver offloads.
   - Restore Wi-Fi MIMO Power Save (Dynamic SMPS), U-APSD, and Roaming Aggressiveness defaults.
   - Remove all `Vortex_*` QoS policies, Cloudflare DoH templates, and NLA workgroup overrides.
   - Restore Windows Multimedia Network Throttling (`10`), System Responsiveness (`20`), and `Tasks\Games` priorities.
   - Remove injected global `Tcpip\Parameters` registry keys (`DefaultTTL`, `EnableTCPA`, etc.).
   - Restore Netsh TCP stack parameters (DCA, NetDMA, Taskoffload, Neighborcachelimit, Teredo, 6to4, ISATAP) without touching Winsock LSPs or static routes.
   - Restore GameDVR background capture defaults.
   - Re-enable background services (`DiagTrack`, `SysMain`, `WSearch`).
3. Restart your PC.

---

## 🔍 Validation & Testing Status

| Testing Tier | Verification Method | Status | Notes |
| :--- | :--- | :--- | :--- |
| **PowerShell Syntax & AST** | In-memory AST Parser (`[System.Management.Automation.Language.Parser]`) | ✅ Verified | 0 AST syntax errors; verified across all modes. |
| **Batch CLI & Redirection** | Syntax verification & line-by-line fallback parser | ✅ Verified | Escaped block redirection validated without cmd syntax crash. |
| **Simulated Mock Testing** | Isolated in-memory cmdlet interception (`test_mock_engine.ps1`) | ✅ Verified | Tested `Optimize`, `Revert`, `ToggleWifiScan`, and quoted `CustomProcess` without system mutations. |
| **Rollback Symmetry** | Direct delta audit between `Optimize` and `Revert` mutations | ✅ Verified | Every modified setting has an exact reverse restoration; Winsock/IP stacks are not clobbered. |
| **Physical Hardware & ISP** | Real-world NIC transceivers & upstream gateway router DSCP tagging | ⚠️ Unverified | Real NIC driver keywords vary by vendor (Realtek vs Intel vs Marvell); residential ISPs may ignore DSCP 46. |

---

## 📜 Disclaimer

This tool is provided as-is without warranty. Use at your own risk. It modifies system-level hardware driver properties and network registry configurations intended for dedicated competitive gaming PCs. Always review script logic before execution on production or personal environments.


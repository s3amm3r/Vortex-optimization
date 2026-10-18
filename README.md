# Vortex Optimization Suite v2.0

**Vortex Optimization Suite** is an advanced Windows batch + PowerShell tuning suite authored by **s3amm3r**, engineered to eliminate micro-stutter, minimize input latency, reduce bufferbloat, and prioritize real-time packet delivery for competitive gaming (specifically Fortnite).

It applies deep bare-metal adjustments to CPU scheduling, network transceivers (Ethernet & Wi-Fi), TCP/IP stacks, DNS-over-HTTPS, QoS DSCP 46 priority rules, GPU scheduling, and background services.

> ⚠️ **Warning**
> This script modifies registry values, network adapter driver properties, and system services.
> While an automated 1-click rollback script (`vortex-revert.bat`) is included, creating a Windows System Restore point before running system tweaks is always recommended.

---

## 📁 Repository Structure

```text
Vortex-optimization/
├── Vortex optimization.bat   # Interactive CLI & Master optimization engine
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
| **Ethernet Tuning** | Disables Interrupt Moderation, Flow Control, Energy Efficient Ethernet (EEE), Green Ethernet; maximizes Ring Buffers (1024). |
| **Wi-Fi Tuning** | Minimizes Roaming Aggressiveness (Lowest), disables Packet Coalescing, enforces No SMPS (full MIMO), disables U-APSD, sets Max Transmit Power. |
| **Wi-Fi Stabilizer** | Integrated toggle to disable Windows WLAN AutoConfig background scanning (eliminating 60-second ping spikes during matches). |
| **Universal NIC Tuning** | Strips LSO, RSC, VMQ, and Checksum hardware offloads; enforces persistent MTU 1500; disables adapter power management. |
| **TCP/IP Stack** | Enforces CUBIC congestion provider, disables Nagle algorithm (`TcpAckFrequency=1`, `TcpDelAckTicks=0`), disables TCP timestamps, sets 2000/300ms RTO. |
| **QoS Priority** | Injects DSCP 46 Expedited Forwarding policies for `FortniteClient-Win64-Shipping.exe` and UDP traffic with workgroup NLA bypass (`Do not use NLA = 1`). |
| **Network Throttling** | Disables Windows Multimedia Network Packet Throttling (`NetworkThrottlingIndex = 0xffffffff`) and CPU reservation (`SystemResponsiveness = 0`). |
| **DNS & DoH** | Configures Cloudflare DNS (`1.1.1.1` / `1.0.0.1`) with native DNS-over-HTTPS (DoH) encrypted templates. |
| **Power & CPU** | Activates Ultimate Performance plan, unparks all cores (`CPMINCORES 100`), bypasses processor sleep idle states (`ProcessorIdleDisable = 1`). |
| **Storage & Cache** | Clears Fortnite prefetch/webcache, Direct3D caches, NVIDIA DXCache, and AMD DxCache. |
| **GPU Scheduling** | Forces Discrete High-Performance GPU preference and enables Windows Hardware-Accelerated GPU Scheduling (HAGS). |
| **Bloat Mitigation** | Kills background sync agents (`OneDrive`, `Cortana`, `Skype`) and disables telemetry services (`DiagTrack`, `SysMain`, `WSearch`). |
| **Automated Rollback** | Includes dedicated `vortex-revert.bat` to restore default Windows network stacks, power schemes, and services. |

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
   - `[1] Full Vortex Optimization` (Recommended for competitive gaming)
   - `[2] Network & Adapter Tuning Only` (Ethernet, Wi-Fi, QoS, and TCP/IP)
   - `[3] Wi-Fi Ping Spike Stabilizer` (Toggle WLAN background scanning)
   - `[4] Rollback to Windows Defaults`
   - `[5] Exit`
3. Restart your PC to allow network drivers and kernel queues to re-bind cleanly.

### Automated / Headless Execution
You can run the script non-interactively using the `/y` or `/auto` switch:
```cmd
"Vortex optimization.bat" /y
```

---

## 🔄 Reverting Changes (Automated Rollback)

Unlike previous iterations, Vortex v2.0 includes a comprehensive, automated 1-click rollback engine:

1. Right-click **`vortex-revert.bat`** and select **Run as Administrator** (or select `[4]` in the main menu).
2. The script will automatically:
   - Reset network adapters back to automatic DHCP.
   - Re-enable Interrupt Moderation, Flow Control, and default driver offloads.
   - Remove `Vortex_Fortnite`, `Vortex_Gaming_UDP`, and `Vortex_EpicGames` QoS policies.
   - Remove the `Do not use NLA` registry bypass.
   - Restore Windows Multimedia Network Throttling (`10`) and System Responsiveness (`20`).
   - Restore default Balanced power plans and re-enable CPU sleep states.
   - Reset TCP/IP, Winsock, and DNS catalogs (`netsh int ip reset`, `netsh winsock reset`).
   - Re-enable background services (`DiagTrack`, `SysMain`, `WSearch`).
3. Restart your PC.

---

## 📜 Disclaimer

This tool is provided as-is without warranty. Use at your own risk. It modifies system-level hardware driver properties and registry configurations intended for dedicated competitive gaming PCs.

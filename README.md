# Vortex Optimizations

**Vortex Optimizations** is a Windows batch + PowerShell tuning script designed to reduce system overhead, improve network responsiveness, and optimize gaming performance (primarily Fortnite).

It applies system-level adjustments to power management, network adapters, TCP/IP behavior, DNS configuration, GPU scheduling, and background services.

> ⚠️ **Warning**
> This script modifies registry values, network adapter settings, and system services. Some changes may affect stability, power usage, or Windows defaults.
> Use only on a dedicated gaming system and create a restore point before running.

---

## 📁 Repository Structure

```text
Vortex-Optimizations/
├── vortex.bat   # Main optimization script
└── README.md
```

---

## 🚀 Features

| Category            | Description                                                                          |
| ------------------- | ------------------------------------------------------------------------------------ |
| **Power & CPU**     | Enables high-performance power plan, reduces CPU power-saving latency features.      |
| **Network Adapter** | Disables offloads (LSO, RSC, VMQ, checksum), optimizes Ethernet behavior.            |
| **TCP/IP Stack**    | Configures congestion control (CUBIC/CTCP), disables select latency features.        |
| **DNS**             | Sets Cloudflare DNS (1.1.1.1 / 1.0.0.1) with DNS-over-HTTPS support where available. |
| **QoS Policy**      | Applies DSCP 46 priority rule for Fortnite traffic.                                  |
| **Storage & Cache** | Clears shader cache, logs, and temporary GPU/DirectX files.                          |
| **GPU Settings**    | Enables high-performance GPU preference and disables fullscreen optimizations.       |
| **Services**        | Disables selected background services (telemetry, indexing, update-related tasks).   |

---

## ❓ FAQ

**Does this increase FPS?**
Indirectly. It reduces background load and improves system responsiveness, but results depend on hardware.

**Is it safe?**
Mostly safe on personal machines, but it modifies system-level settings. Creating a restore point is recommended.

**Will it work on Wi-Fi?**
Yes. Ethernet-only tweaks are skipped or ignored where unsupported.

**Why do some commands fail?**
Some drivers or Windows builds don’t expose certain features. These errors are harmless.

**Will it update?**
Probably. Updates depend on stability testing and whether new Windows changes break existing tweaks. And if people want it, i will recode it to rust to make it better and prob paid 😉

---

## 🧪 Usage

1. Download `vortex.bat`
2. Run as **Administrator**
3. Accept the warning prompt
4. Wait for completion
5. Restart your PC (recommended)
6. Optionally launch Fortnite from the prompt

---

## 🔧 Technical Overview

### Power Configuration

* Applies high-performance power plan
* Reduces CPU power-saving latency features

---

### Network Optimization (PowerShell)

* Disables LSO, RSC, VMQ, checksum offload
* Sets Cloudflare DNS + DoH (where supported)
* Optimizes Ethernet adapter behavior when available

---

### TCP/IP Stack Tweaks

* Congestion control: CUBIC (fallback: CTCP)
* Disables TCP timestamps and ECN
* Adjusts ARP and gateway behavior

---

### QoS Configuration

* Targets: `FortniteClient-Win64-Shipping.exe`
* DSCP: 46 (Expedited Forwarding)
* Wildcard routing rules applied

---

### GPU & System Settings

* Forces high-performance GPU preference
* Disables fullscreen optimizations
* Enables hardware-accelerated GPU scheduling (if supported)

---

## 🔄 Reverting Changes

This script does not include automatic rollback.

| Component     | Revert Method                               |
| ------------- | ------------------------------------------- |
| Power plan    | `powercfg -restoredefaultschemes`           |
| Network stack | `netsh int ip reset`                        |
| DNS           | Set adapter back to DHCP                    |
| QoS           | Remove policy in Group Policy / Registry    |
| Services      | Restore defaults in `services.msc`          |
| GPU           | Disable Hardware-Accelerated GPU Scheduling |

### Full Network Reset

```cmd
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
```

Restart required.

---

## 📜 Disclaimer

This tool is provided as-is without warranty. Use at your own risk. It may affect system stability depending on hardware and Windows version.

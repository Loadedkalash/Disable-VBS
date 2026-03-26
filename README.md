# VBS Manager

A PowerShell script to disable or re-enable **VBS (Virtualization Based Security)** on Windows 11 using Microsoft's official **DG_Readiness_Tool v3.6**.

---

## Why disable VBS?

VBS is a Windows security layer that leverages the hypervisor to isolate sensitive processes (Credential Guard, HVCI...). However, it consumes a noticeable amount of CPU/GPU resources, which can negatively impact gaming performance (FPS, 1% lows) or other demanding applications.

---

## Why this method?

Unlike scripts that manually modify the BCD or registry, this script uses the official Microsoft tool designed specifically for this purpose. It is:

- ✅ **Secure Boot compatible** — no modification to the boot trust chain
- ✅ **Fully reversible** — option 2 restores Windows defaults at any time
- ✅ **SVM / VT-x preserved** — BIOS virtualization stays active, your VMs and emulators keep working
- ✅ **Official Microsoft tool** — no risky registry or BCD tampering

---

## Usage

1. Download the script
2. Right-click → **Run with PowerShell as Administrator**
3. Select an option:

```
  1  →  Disable VBS  (performance gain)
  2  →  Enable VBS   (Windows 11 default settings)
```

### On reboot

| Option | Screen | Key |
|--------|--------|-----|
| Disable | Credential Guard | **Esc** (skip) |
| Disable | Hyper-V / VBS | **F3** (confirm) |
| Enable | Confirmation | **Enter** |

---

## Requirements

- Windows 11 (tested on 23H2 and 24H2)
- PowerShell running as Administrator
- Internet connection (DG_Readiness_Tool is downloaded automatically)

---

## Resources

- [DG_Readiness_Tool v3.6 — Microsoft](https://www.microsoft.com/en-us/download/details.aspx?id=53337)

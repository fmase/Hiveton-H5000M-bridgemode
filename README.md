# Hiveton H5000M — Bridge Mode with Quectel RM551E-GL (iamromulan)

Documented setup of a **Hiveton H5000M** router running **ImmortalWrt 24.10** in bridge mode with a **Quectel RM551E-GL** 5G module using the custom [iamromulan](https://github.com/iamromulan) firmware.

> 🇮🇹 [Leggi in italiano](README.it.md)

## Hardware

| Device | Description |
|---|---|
| **Hiveton H5000M** | WiFi 6 router, MediaTek MT7992, ARMv8 quad-core |
| **Quectel RM551E-GL** | 5G SA/NSA module, iamromulan firmware (OpenWrt 23.05.4) |

<p align="center">
  <img src="images/AIRPI-1.jpg" width="45%" alt="Hiveton H5000M"/>
  <img src="images/ROMULANO-1.jpg" width="45%" alt="Quectel RM551E-GL"/>
</p>
<p align="center">
  <em>Hiveton H5000M (left) — Quectel RM551E-GL with antenna cables (right)</em>
</p>

### Inside look

<p align="center">
  <img src="images/AIRPI-3.jpg" width="45%" alt="H5000M PCB"/>
  <img src="images/AIRPI-4.jpg" width="45%" alt="H5000M internal with RM551"/>
</p>
<p align="center">
  <em>H5000M PCB (left) — RM551E-GL module installed inside the H5000M (right)</em>
</p>

## Concept

The Quectel RM551E-GL module is connected to the H5000M router via USB. Thanks to the `cdc_ether` driver, the module is exposed as a standard Ethernet interface (`usb0`) and bridged together with the physical LAN port (`eth1`) and the 5GHz WiFi radio (`rai0`).

The result is a flat network where the 5G module acts as the internet gateway for all WiFi and LAN clients — no double NAT.

## Repository structure

```
├── airpi/
│   └── scripts/
│       ├── bannerwrt.sh        # ASCII tricolor SSH banner
│       ├── info.sh             # Dynamic quick info on login
│       └── profile.d/
│           └── airpi_motd.sh   # MOTD launcher on login
├── romulano/
│   └── scripts/
│       ├── bannerwrt.sh        # ASCII tricolor SSH banner
│       └── info.sh             # Dynamic quick info on login
└── docs/
    ├── architecture.md         # Network diagram and bridge mode explanation
    ├── setup-airpi.md          # H5000M configuration guide
    └── setup-romulano.md       # Quectel RM551E-GL configuration guide
```

## Firmware

- **H5000M:** `immortalwrt-mediatek-filogic-hiveton-h5000m-squashfs-sysupgrade.bin` — ImmortalWrt 24.10-SNAPSHOT
- **Quectel RM551E-GL:** iamromulan firmware — `RM551EGL00AAR02A02M8G_2025_12_08_iamromulan_basic_eth`

## What was configured

- Bridge `br-lan` = `eth1` + `usb0` + `rai0` (WiFi 6 / 5GHz / HE80)
- H5000M without NAT — direct gateway via Quectel RM551E-GL module
- DHCP with `authoritative=1`, gateway and DNS pointing to the module
- Full ModemManager cleanup (not needed with `cdc_ether`)
- Removal of pre-installed bandix from iamromulan firmware on the Quectel RM551E-GL (~330 MB RAM freed)
- `irqbalance` enabled
- Flow offloading disabled (required for bandix/eBPF monitoring)
- [bandix](https://github.com/timsaya/openwrt-bandix) + [luci-app-bandix](https://github.com/timsaya/luci-app-bandix) installed for real-time traffic monitoring
- Custom MOTD on both devices (tricolor ASCII banner + quick info)
- ZeroTier for remote access

## Compatibility

Although this setup was tested with the **Quectel RM551E-GL**, it can be reproduced with any module supported by [iamromulan](https://github.com/iamromulan)'s custom firmware. The iamromulan project provides OpenWrt-based firmware for several Quectel modules — check his GitHub for the full list of supported devices.

> Full credit for the module firmware goes to **[iamromulan](https://github.com/iamromulan)** — without his work this setup would not be possible.

## Notes

- Periodic LTE disconnections (~4h) are normal in my case — I use a WindTre SIM and the carrier renegotiates the IP every ~4 hours
- SQM/cake cannot be installed on either device (kmod unavailable for these architectures)

# Hiveton H5000M — Bridge Mode with Quectel RM551E-GL (iamromulan)

Documented setup of a **Hiveton H5000M** router running **ImmortalWrt 24.10** in bridge mode with a **Quectel RM551E-GL** 5G module using the custom [iamromulan](https://github.com/iamromulan) firmware.

> 🇮🇹 [Leggi in italiano](README.it.md)

## Hardware

| Device | Description |
|---|---|
| **Hiveton H5000M** | WiFi 6 router, MediaTek MT7992, ARMv8 quad-core |
| **Quectel RM551E-GL** | 5G SA/NSA module, iamromulan firmware (OpenWrt 23.05.4) |

## Concept

The RM551E-GL module is connected to the H5000M router via USB. Thanks to the `cdc_ether` driver, the module is exposed as a standard Ethernet interface (`usb0`) and bridged together with the physical LAN port (`eth1`) and the 5GHz WiFi radio (`rai0`).

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
    └── setup-romulano.md       # RM551E-GL configuration guide
```

## Firmware

- **H5000M:** `immortalwrt-mediatek-filogic-hiveton-h5000m-squashfs-sysupgrade.bin` — ImmortalWrt 24.10-SNAPSHOT
- **RM551E-GL:** iamromulan firmware — `RM551EGL00AAR02A02M8G_2025_12_08_iamromulan_basic_eth`

## What was configured

- Bridge `br-lan` = `eth1` + `usb0` + `rai0` (WiFi 6 / 5GHz / HE80)
- H5000M without NAT — direct gateway via 5G module
- DHCP with `authoritative=1`, gateway and DNS pointing to the module
- Full ModemManager cleanup (not needed with `cdc_ether`)
- Removal of pre-installed bandix from iamromulan firmware (~330 MB RAM freed)
- `irqbalance` enabled
- Flow offloading disabled (eBPF/bandix compatibility)
- Custom MOTD on both devices (tricolor ASCII banner + quick info)
- ZeroTier for remote access

## Notes

- Periodic LTE disconnects (~4h) are normal — SIM renegotiates IP
- SQM/cake cannot be installed on either device (kmod unavailable for these architectures)
- AT commands on the module: use `atinout` on `/dev/pts/1` (socat PTY bridge)

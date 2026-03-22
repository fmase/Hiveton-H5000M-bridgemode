# ROMULANO Setup — Quectel RM551E-GL

> 🇮🇹 [Leggi in italiano](setup-romulano.it.md)

## Firmware

- **iamromulan custom firmware** — OpenWrt 23.05.4 `r24012-d8dd03c46f`
- Build: `RM551EGL00AAR02A02M8G_2025_12_08_iamromulan_basic_eth`
- Target: `RM551E-GL`
- Arch: `aarch64_cortex-a53` (Qualcomm sdxpinn SoC)

Firmware available at: [github.com/iamromulan](https://github.com/iamromulan)

## SSH access

The module is reachable via SSH when connected via USB to the H5000M router (gateway IP of the local network).

## Packages to remove after flashing

The iamromulan firmware ships with bandix pre-installed (~276 MB VSZ). Remove it to free RAM:

```sh
# Remove bandix
opkg remove bandix luci-app-bandix

# Remove Tailscale if present
opkg remove tailscale
```

Total RAM freed: ~330 MB

## Hostname

```sh
uci set system.@system[0].hostname='ROMULANO'
uci commit system
/etc/init.d/system reload
```

## Data interface

- Active interface: `rmnet_data0`
- `rmnet_data1` is normally down — this is expected

## AT commands

```sh
# Use atinout on the socat-at-bridge PTY
atinout - /dev/pts/1 -
# Do NOT use /dev/ttyUSB2 or /dev/smd7 directly
```

## Kernel limitations (sdxpinn arch)

- `tc` not available — no traffic shaping
- `kmod-sched-cake` and `fq_codel` cannot be installed
- SQM is impossible on this firmware

## Operational notes

- Periodic LTE disconnects (~4h) are normal — SIM renegotiates IP
- ZeroTier is often unreachable via public network — prefer LAN access
- Verified connection: LTE B20 (PCC) + NR5G B78 (SCC) in NSA EN-DC mode

## MOTD / SSH Banner

Copy scripts from `romulano/scripts/`:

```sh
cp bannerwrt.sh /etc/bannerwrt.sh
cp info.sh /etc/info.sh
chmod +x /etc/bannerwrt.sh /etc/info.sh
```

The module does not have `/etc/profile.d/` — add the script calls directly to `/etc/profile` or `/etc/rc.local` if needed.

Replace `YOUR_ZT_IFACE` in `info.sh` with your actual ZeroTier interface name.

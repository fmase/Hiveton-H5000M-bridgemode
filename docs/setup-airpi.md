# AIRPI Setup — Hiveton H5000M

> 🇮🇹 [Leggi in italiano](setup-airpi.it.md)

## Firmware

- **ImmortalWrt 24.10-SNAPSHOT** `r33349-a35c3c2753`
- Target: `mediatek/filogic`
- Arch: `aarch64_cortex-a53`
- File: `immortalwrt-mediatek-filogic-hiveton-h5000m-squashfs-sysupgrade.bin`

## Network configuration

```sh
uci set network.@device[0].name='br-lan'
uci set network.@device[0].type='bridge'
uci set network.@device[0].ports='eth1 usb0'
uci set network.lan.device='br-lan'
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.X.100'
uci set network.lan.netmask='255.255.255.0'
uci set network.lan.gateway='192.168.X.1'
uci set network.lan.dns='192.168.X.1'
uci commit network
```

## DHCP configuration

```sh
uci set dhcp.lan.start='101'
uci set dhcp.lan.limit='10'
uci set dhcp.lan.leasetime='12h'
uci set dhcp.@dnsmasq[0].authoritative='1'
uci add_list dhcp.lan.dhcp_option='3,192.168.X.1'
uci add_list dhcp.lan.dhcp_option='6,192.168.X.1'
uci commit dhcp
/etc/init.d/dnsmasq restart
```

## WiFi 5GHz (WiFi 6 / HE80)

```sh
uci set wireless.MT7992_1_2.channel='48'
uci set wireless.MT7992_1_2.htmode='HE80'
uci set wireless.MT7992_1_2.txpower='100'
uci set wireless.MT7992_1_2.country='US'
uci set wireless.default_MT7992_1_2.mode='ap'
uci set wireless.default_MT7992_1_2.encryption='psk2'
# Disable 2.4GHz
uci set wireless.MT7992_1_1.disabled='1'
uci commit wireless
wifi reload
```

## Packages installed

```sh
opkg update
opkg install openssh-sftp-server nano-full whois nmap vnstat bash \
  bind-tools bind-host lm-sensors curl irqbalance \
  luci-mod-dashboard luci-app-irqbalance luci-theme-openwrt-2020
```

## Packages removed (ModemManager cleanup)

Not needed with iamromulan firmware + `cdc_ether` driver:

```sh
opkg remove modemmanager luci-proto-modemmanager libmbim mbim-utils umbim \
  luci-proto-mbim libqmi uqmi luci-proto-qmi comgt comgt-ncm chat wwan \
  xmm-modem luci-proto-xmm luci-proto-ncm luci-proto-quectel \
  luci-app-sms-tool-js sms-tool luci-app-3ginfo-lite luci-app-modemband \
  modemband luci-app-epm
```

## Performance / QoS

```sh
# Enable irqbalance
uci set irqbalance.irqbalance.enabled=1
uci commit irqbalance
/etc/init.d/irqbalance start

# Disable flow offloading (required for bandix/eBPF)
uci set firewall.@defaults[0].flow_offloading='0'
uci commit firewall
/etc/init.d/firewall restart
```

> **Note:** `kmod-sched-cake` and SQM are not available for this architecture.

## Monitoring — bandix

- Install `bandix` (eBPF backend `aarch64_cortex-a53`) + `luci-app-bandix`
- Monitor interface: `br-lan`
- Web UI port: `8686`
- Flow offloading must be **disabled** (prerequisite)

## MOTD / SSH Banner

Copy scripts from `airpi/scripts/`:

```sh
cp bannerwrt.sh /etc/bannerwrt.sh
cp info.sh /etc/info.sh
cp profile.d/airpi_motd.sh /etc/profile.d/airpi_motd.sh
chmod +x /etc/bannerwrt.sh /etc/info.sh /etc/profile.d/airpi_motd.sh

# Clear static banner
echo "" > /etc/banner
```

Replace `YOUR_ZT_IFACE` in `info.sh` with your actual ZeroTier interface name.

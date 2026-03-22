# Setup AIRPI — Hiveton H5000M

## Firmware

- **ImmortalWrt 24.10-SNAPSHOT** `r33349-a35c3c2753`
- Target: `mediatek/filogic`
- Arch: `aarch64_cortex-a53`
- File: `immortalwrt-mediatek-filogic-hiveton-h5000m-squashfs-sysupgrade.bin`

## Configurazione rete

```
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

## Configurazione DHCP

```
uci set dhcp.lan.start='101'
uci set dhcp.lan.limit='10'
uci set dhcp.lan.leasetime='12h'
uci set dhcp.@dnsmasq[0].authoritative='1'
uci add_list dhcp.lan.dhcp_option='3,192.168.X.1'
uci add_list dhcp.lan.dhcp_option='6,192.168.X.1'
uci commit dhcp
/etc/init.d/dnsmasq restart
```

## Configurazione WiFi 5GHz (WiFi 6 / HE80)

```
uci set wireless.MT7992_1_2.channel='48'
uci set wireless.MT7992_1_2.htmode='HE80'
uci set wireless.MT7992_1_2.txpower='100'
uci set wireless.MT7992_1_2.country='US'
uci set wireless.default_MT7992_1_2.mode='ap'
uci set wireless.default_MT7992_1_2.encryption='psk2'
# 2.4GHz disabilitata
uci set wireless.MT7992_1_1.disabled='1'
uci commit wireless
wifi reload
```

## Pacchetti installati

```sh
opkg update
opkg install openssh-sftp-server nano-full whois nmap vnstat bash \
  bind-tools bind-host lm-sensors curl irqbalance \
  luci-mod-dashboard luci-app-irqbalance luci-theme-openwrt-2020
```

## Pacchetti rimossi (cleanup ModemManager)

Non necessari con firmware iamromulan + driver cdc_ether:

```sh
opkg remove modemmanager luci-proto-modemmanager libmbim mbim-utils umbim \
  luci-proto-mbim libqmi uqmi luci-proto-qmi comgt comgt-ncm chat wwan \
  xmm-modem luci-proto-xmm luci-proto-ncm luci-proto-quectel \
  luci-app-sms-tool-js sms-tool luci-app-3ginfo-lite luci-app-modemband \
  modemband luci-app-epm
```

## Performance / QoS

```sh
# irqbalance
uci set irqbalance.irqbalance.enabled=1
uci commit irqbalance
/etc/init.d/irqbalance start

# Flow offloading — disabilitare se si usa bandix/eBPF
uci set firewall.@defaults[0].flow_offloading='0'
uci commit firewall
/etc/init.d/firewall restart
```

> **Nota:** `kmod-sched-cake` e SQM non sono disponibili per questa architettura.

## Monitoring — bandix

- Installa `bandix` (backend eBPF `aarch64_cortex-a53`) + `luci-app-bandix`
- Interfaccia: `br-lan`
- Porta: `8686`
- Flow offloading deve essere **disabilitato** (prerequisito)

## MOTD / Banner SSH

Copiare gli script dalla cartella `airpi/scripts/`:

```sh
# Sul router
cp bannerwrt.sh /etc/bannerwrt.sh
cp info.sh /etc/info.sh
cp profile.d/airpi_motd.sh /etc/profile.d/airpi_motd.sh
chmod +x /etc/bannerwrt.sh /etc/info.sh /etc/profile.d/airpi_motd.sh

# Svuotare il banner statico
echo "" > /etc/banner
```

Sostituire `YOUR_ZT_IFACE` in `info.sh` con il nome dell'interfaccia ZeroTier locale.

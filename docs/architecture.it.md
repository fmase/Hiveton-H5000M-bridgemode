# Architettura di rete

> 🇬🇧 [Read in English](architecture.md)

## Hardware

| Dispositivo | Ruolo |
|---|---|
| **Hiveton H5000M** (MediaTek MT7992, 4-core ARMv8) | Router OpenWRT — bridge + WiFi AP |
| **Quectel RM551E-GL** (firmware [iamromulan](https://github.com/iamromulan)) | Modulo 5G — gateway internet + DHCP server |

## Schema rete

```
Internet (5G/LTE)
      │
  [RM551E-GL]  ←── firmware: iamromulan (OpenWrt 23.05.4)
  192.168.X.1      DHCP server, gateway
      │
     usb0  (CDC Ethernet / cdc_ether)
      │
  [H5000M]  ←── ImmortalWrt 24.10-SNAPSHOT
  192.168.X.100    br-lan = eth1 + usb0 + rai0
      │
    rai0  (WiFi 6 / HE80 / 5GHz)
      │
   Client WiFi / LAN
   (range DHCP .101–.110)
```

## Bridge mode — concetto

Il modulo RM551E-GL è collegato al router H5000M via USB. Il driver utilizzato è `cdc_ether` (interfaccia `usb0`), che espone il modulo come una normale interfaccia Ethernet.

Il bridge `br-lan` unisce:
- `eth1` — porta LAN fisica
- `usb0` — modulo 5G via USB
- `rai0` — radio WiFi 5GHz

Tutto il traffico dei client WiFi e LAN passa direttamente attraverso il modulo 5G, che fa da gateway. Il router H5000M non fa NAT — è in **bridge mode**.

## Ruolo DHCP

Il DHCP è gestito dal router H5000M (dnsmasq, `authoritative=1`), con opzione DHCP 3 che punta al gateway del modulo RM551. I client ricevono:
- IP nel range `.101`–`.110`
- Gateway: IP del modulo RM551
- DNS: IP del modulo RM551

## Nota sui driver

Il modulo Quectel RM551E-GL con firmware [iamromulan](https://github.com/iamromulan) usa `cdc_ether` (USB CDC Ethernet). I driver QMI/MBIM non sono necessari e possono essere rimossi da ImmortalWrt per liberare spazio e semplificare la configurazione.

## Monitoraggio

Il monitoraggio del traffico è gestito da [bandix](https://github.com/timsaya/openwrt-bandix) (basato su eBPF) con [luci-app-bandix](https://github.com/timsaya/luci-app-bandix) per l'interfaccia web LuCI. Il flow offloading deve essere disabilitato affinché bandix funzioni correttamente.

> Crediti: [timsaya](https://github.com/timsaya)

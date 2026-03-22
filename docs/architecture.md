# Network Architecture

> 🇮🇹 [Leggi in italiano](architecture.it.md)

## Hardware

| Device | Role |
|---|---|
| **Hiveton H5000M** (MediaTek MT7992, 4-core ARMv8) | OpenWrt router — bridge + WiFi AP |
| **Quectel RM551E-GL** (iamromulan firmware) | 5G module — internet gateway + DHCP server |

## Network diagram

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
   WiFi / LAN clients
   (DHCP range .101–.110)
```

## Bridge mode — concept

The RM551E-GL module is connected to the H5000M via USB. The `cdc_ether` driver exposes the module as a standard Ethernet interface (`usb0`).

The `br-lan` bridge combines:
- `eth1` — physical LAN port
- `usb0` — 5G module via USB
- `rai0` — 5GHz WiFi radio

All WiFi and LAN client traffic flows directly through the 5G module, which acts as the gateway. The H5000M does **not** perform NAT — it operates in **bridge mode**.

## DHCP

DHCP is handled by the H5000M (dnsmasq, `authoritative=1`), with DHCP option 3 pointing to the RM551 module. Clients receive:
- IP in range `.101`–`.110`
- Gateway: RM551 module IP
- DNS: RM551 module IP

## Driver note

The RM551E-GL with iamromulan firmware uses `cdc_ether` (USB CDC Ethernet). QMI/MBIM drivers are not needed and can be safely removed from ImmortalWrt to free space and simplify the setup.

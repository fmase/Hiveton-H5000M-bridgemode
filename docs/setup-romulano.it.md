# Setup ROMULANO — Quectel RM551E-GL

## Firmware

- **iamromulan custom firmware** — OpenWrt 23.05.4 `r24012-d8dd03c46f`
- Build: `RM551EGL00AAR02A02M8G_2025_12_08_iamromulan_basic_eth`
- Target: `RM551E-GL`
- Arch: `aarch64_cortex-a53` (Qualcomm sdxpinn SoC)

Firmware disponibile su: [github.com/iamromulan](https://github.com/iamromulan)

## Accesso SSH

Il modulo è raggiungibile via SSH sulla porta standard quando connesso via USB al router H5000M (IP gateway della rete locale).

## Pacchetti da rimuovere subito dopo il flash

Il firmware iamromulan include bandix pre-installato (circa 276 MB VSZ). Va rimosso per liberare RAM:

```sh
# Rimuovi bandix
opkg remove bandix luci-app-bandix

# Rimuovi Tailscale se presente
opkg remove tailscale
```

Memoria liberata totale: ~330 MB

## Hostname

```sh
uci set system.@system[0].hostname='ROMULANO'
uci commit system
/etc/init.d/system reload
```

## Interfaccia dati

- Interfaccia attiva: `rmnet_data0`
- `rmnet_data1` normalmente down — non è un problema

## AT commands

```sh
# Usare atinout sulla PTY del socat-at-bridge
atinout - /dev/pts/1 -
# NON usare /dev/ttyUSB2 o /dev/smd7 direttamente
```

## Limitazioni kernel (sdxpinn)

- `tc` non disponibile — nessun traffic shaping
- `kmod-sched-cake` e `fq_codel` non installabili
- SQM impossibile su questo firmware

## Note operative

- La SIM può rinegoziare l'IP ogni ~4 ore — i disconnect nel log sono normali
- ZeroTier spesso non raggiungibile via rete pubblica — preferire accesso LAN
- Connessione verificata: LTE B20 (PCC) + NR5G B78 (SCC) in NSA EN-DC

## MOTD / Banner SSH

Copiare gli script dalla cartella `romulano/scripts/`:

```sh
cp bannerwrt.sh /etc/bannerwrt.sh
cp info.sh /etc/info.sh
chmod +x /etc/bannerwrt.sh /etc/info.sh
```

Il modulo non ha `/etc/profile.d/` — aggiungere il lancio degli script direttamente in `/etc/profile` o `/etc/rc.local` se necessario.

Sostituire `YOUR_ZT_IFACE` in `info.sh` con il nome dell'interfaccia ZeroTier locale.

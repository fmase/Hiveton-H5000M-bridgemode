#!/bin/ash
# info.sh — Quick Info (AIRPI)
# mc edition 📡

ESC="$(printf '\033')"
G="${ESC}[1;32m"
Y="${ESC}[1;33m"
R="${ESC}[1;31m"
C="${ESC}[1;36m"
B="${ESC}[1m"
N="${ESC}[0m"

uptime_human() {
  awk '{t=int($1); h=int(t/3600); m=int((t%3600)/60);
       printf "%02dh %02dm", h,m}' /proc/uptime
}

lan4() {
  ip -4 addr show br-lan 2>/dev/null \
  | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1
}

gw4() {
  ip route | awk '/default/{print $3}' | head -n1
}

rx_tx() {
  awk '
    NR>2 && $1 ~ /br-lan:/ {
      printf "%.2f %.2f", $2/1073741824, $10/1073741824
    }' /proc/net/dev
}

zt_ip() {
  # Replace YOUR_ZT_IFACE with your actual ZeroTier interface name
  ip -4 addr show YOUR_ZT_IFACE 2>/dev/null \
  | awk '/inet /{print $2}' | cut -d/ -f1
}

cpu_temp() {
  for z in /sys/class/thermal/thermal_zone*; do
    [ -f "$z/temp" ] || continue
    v="$(cat "$z/temp" 2>/dev/null)"
    [ -n "$v" ] && [ "$v" -gt 0 ] && {
      awk -v n="$v" -v g="$G" -v y="$Y" -v r="$R" -v rst="$N" \
        'BEGIN{d=n/1000; w=int(d); col=(w<=39)?g:(w<=49)?y:r; printf "%s%.1f°C%s",col,d,rst}'
      return
    }
  done
  printf "-"
}

HOST="$(uname -n)"
DATE="$(date '+%Y-%m-%d %H:%M:%S')"
UP="$(uptime_human)"
L4="$(lan4)"
GW="$(gw4)"

set -- $(rx_tx)
RX="$1"
TX="$2"

printf "🌐 ${C}${B}Quick Info${N}\n\n"
printf "📛 ${B}Hostname:${N} ${G}%s${N}\n" "$HOST"
printf "🕒 ${B}Data/Ora:${N} ${G}%s${N}\n" "$DATE"
printf "⏱️ ${B}Uptime:${N} ${G}%s${N}\n" "$UP"
printf "🌐 ${B}LAN IP:${N} ${G}%s${N}\n" "$L4"
printf "🔗 ${B}Gateway:${N} ${G}%s${N}\n" "$GW"
printf "📥 ${B}RX:${N} ${G}%s GB${N} | 📤 ${B}TX:${N} ${G}%s GB${N}\n" "$RX" "$TX"

ZT="$(zt_ip)"
[ -n "$ZT" ] && printf "🟢 ${B}ZeroTier:${N} ${G}%s${N}\n" "$ZT"
printf "🌡️ ${B}Temp CPU:${N} %s\n" "$(cpu_temp)"

. /etc/os-release 2>/dev/null
[ -n "$OPENWRT_RELEASE" ] && \
printf "\n🧩 ${B}Firmware:${N} ${G}%s${N}\n" "$OPENWRT_RELEASE"
printf "\n"
printf "📡 ${G}HIVETON H5000M router — AIRPI${N}\n"
printf "\n"

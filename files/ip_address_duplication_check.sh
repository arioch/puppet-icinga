#!/bin/bash

# This file is managed by puppet

# ignore localhost, and addresses with subnet /32 (because of Hetzner failover IP)
ips=$(ip addr show | grep "inet\b" |  awk '{print $2}' | grep -E -v '127\.0\.0\.1|\/32' | cut -d/ -f1)
interfaces=$(ls /sys/class/net/)
duplications=''

arping=$(which arping) || { echo 'UNKNOWN - arping command not found'; exit 3; }

for ip in $ips
do
  for iface in $interfaces
  do
    $arping -q -D -c 1 -I "$iface" "$ip" &>/dev/null
    [[ $? -ne 0 ]] && duplications="${duplications}${ip} "
  done
done

if [[ -z "$duplications" ]]; then
  echo "OK - No duplicate address found."
  exit 0
else
  echo "CRITICAL - Found duplicate addresses: ${duplications}!!!"
  exit 2
fi

#!/bin/bash

# This file is managed by puppet

# ignore localhost, and addresses with subnet /32 (because of Hetzner failover IP)
ips=$(ip addr show | grep "inet\b" |  awk '{print $2}' | grep -E -v '127\.0\.0\.1|\/32' | cut -d/ -f1)
interfaces=$(ip link show | grep 'state UP' | cut -d ':' -f2 | tr -d ' ' | grep -v '\-drac')
duplications=''
arping_output=''

arping=$(which arping) || { echo 'UNKNOWN - arping command not found'; exit 3; }

for ip in $ips
do
  for iface in $interfaces
  do
    arping_output="${arping_output}\n\n$($arping -D -c 1 -I "$iface" "$ip")"
    [[ $? -ne 0 ]] && duplications="${duplications}${ip} "
  done
done

if [[ -z "$duplications" ]]; then
  echo -e "OK - No duplicate address found.${arping_output}"
  exit 0
else
  echo -e "CRITICAL - Found duplicate addresses: ${duplications}!!!${arping_output}"
  exit 2
fi

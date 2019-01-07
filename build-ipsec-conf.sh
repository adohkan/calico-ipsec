#!/bin/sh
set -eu

get_left_ip() {
    local dev="$(
        ip -o route show | \
        awk '
            /^default via/ { print gensub(/^.* dev ([^ ]*) .*$/, "\\1", "g", $0); exit; }
        ')"
    local ip="$(
        ip -4 -o addr show dev "$dev" | \
        awk '
            / inet / { print gensub(/^.* inet ([^\/]*)\/.*$/, "\\1", "g", $0); exit; }
        ')"
    echo "$ip"
}

# IPIP protocol number is 4; 94 is old/unused
PROTOPORT="${IPSEC_PROTOPORT:-[4/]}"

LEFT_IP="$(get_left_ip)"
LEFT_NAME="to"
LEFT_SUBNET="${LEFT_IP}/32"

cat <<HEADER
# /etc/ipsec.conf - strongSwan IPsec configuration file

config setup

conn %default
    authby=${IPSEC_AUTHBY:-pubkey}
    auto=${IPSEC_AUTO_PARAM:-route}

HEADER

ip -oneline route show | awk '/ via .* proto bird / { print $3; }' | sort -u | while read RIGHT_IP; do
    RIGHT_NAME="$(echo "$RIGHT_IP" | sed 's/\./_/g')"
    RIGHT_SUBNET="${RIGHT_IP}/32"
    cat <<CONN
conn ${LEFT_NAME}_${RIGHT_NAME}
    left=${LEFT_IP}
    leftsubnet=${LEFT_SUBNET}${PROTOPORT}
    right=${RIGHT_IP}
    rightsubnet=${RIGHT_SUBNET}${PROTOPORT}

CONN
done

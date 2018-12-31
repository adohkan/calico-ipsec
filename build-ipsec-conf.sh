#!/bin/bash
set -eu
set -o pipefail

get_bird_routes() {
    ip -oneline route show | grep -F 'proto bird'
}

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

get_left_subnet() {
    declare -n routes="${1:?no routes variable passed}"
    awk '
        /^blackhole / { print $2; exit; }
    ' <<< "$routes"
}

get_right_ip_and_subnet() {
    declare -n routes="${1:?no routes variable passed}"
    awk '
        / via / { print $3 " " $1; }
    ' <<< "$routes"
}

BIRD_ROUTES="$(get_bird_routes)"
LEFT_IP="$(get_left_ip)"
LEFT_NAME="to"
LEFT_SUBNET="$(get_left_subnet BIRD_ROUTES)"

cat <<HEADER
# /etc/ipsec.conf - strongSwan IPsec configuration file

config setup

conn %default
    authby=${IPSEC_AUTHBY:-pubkey}
    auto=route

HEADER

get_right_ip_and_subnet BIRD_ROUTES | \
    while read RIGHT_IP RIGHT_SUBNET; do
        RIGHT_NAME="$(sed 's/\./_/g' <<< "$RIGHT_IP")"
        cat <<CONN
conn ${LEFT_NAME}_${RIGHT_NAME}
    left=${LEFT_IP}
    leftsubnet=${LEFT_SUBNET}
    right=${RIGHT_IP}
    rightsubnet=${RIGHT_SUBNET}

CONN
    done

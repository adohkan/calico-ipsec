# calico-ipsec
IPsec for Kubernetes clusters with Calico in IPIP mode

## Minimal disruption deployment

1. First start Daemonset with `IPSEC_AUTO_PARAM` set to `add` - that will load all the connections without starting them.
2. Then modify Daemonset environment variable `IPSEC_AUTO_PARAM` to `route` - Strongswan will install kernel traps for traffic and will start the connection automatically.

## MTU overhead

Tunnel configuration `AES_CBC_128/HMAC_SHA2_256_128` - best case overhead is 62, worst 77. MTU on veth should be 1500(base)-20(ipencap)-62(ipsec) so 1418.

## Fixes

- mention firewall rules

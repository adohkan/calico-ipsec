# calico-ipsec
IPsec for Kubernetes clusters with Calico in IPIP mode

## Minimal disruption deployment

1. First start Daemonset with `IPSEC_AUTO_PARAM` set to `add` - that will load all the connections without starting them.
2. Then modify Daemonset environment variable `IPSEC_AUTO_PARAM` to `route` - Strongswan will install kernel traps for traffic and will start the connection automatically.

## Fixes

- mention MTU requirements
- mention firewall rules

FROM alpine:3.8
COPY ipsec.conf /etc/ipsec.conf
COPY ipsec.secrets /etc/ipsec.secrets
COPY build-ipsec-conf.sh /usr/local/bin/
RUN apk add --no-cache tini strongswan

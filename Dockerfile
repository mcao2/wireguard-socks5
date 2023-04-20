# Expose a WireGuard connection as SOCKS5 proxy
# ARM64 version

FROM arm64v8/alpine

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk add --update-cache dante-server wireguard-tools openresolv ip6tables linux-headers \
  && rm -rf /var/cache/apk/*

COPY ./sockd_v4v6.conf /etc/sockd.conf
COPY ./entrypoint.sh /entrypoint.sh

# Enable IPv6 forwarding
RUN echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf && \
  echo "net.ipv6.conf.default.forwarding=1" >> /etc/sysctl.conf && \
  echo "net.ipv6.conf.all.proxy_ndp=1" >> /etc/sysctl.conf && \
  echo "net.ipv6.conf.default.proxy_ndp=1" >> /etc/sysctl.conf

RUN \
  sed -i 's/^\(tty\d\:\:\)/#\1/' /etc/inittab && \
  sed -i 's/cmd sysctl -q \(.*\?\)=\(.*\)/[[ "$(sysctl -n \1)" != "\2" ]] \&\& \0/' /usr/bin/wg-quick

EXPOSE 1080

ENTRYPOINT "/entrypoint.sh"

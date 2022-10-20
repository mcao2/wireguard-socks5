# Expose a WireGuard connection as SOCKS5 proxy
# ARM64 version

FROM arm64v8/alpine

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk add --update-cache dante-server wireguard-tools openresolv ip6tables linux-headers \
  && rm -rf /var/cache/apk/*

COPY ./sockd.conf /etc/
COPY ./entrypoint.sh /entrypoint.sh

RUN \
  sed -i 's/^\(tty\d\:\:\)/#\1/' /etc/inittab && \
  sed -i 's/cmd sysctl -q \(.*\?\)=\(.*\)/[[ "$(sysctl -n \1)" != "\2" ]] \&\& \0/' /usr/bin/wg-quick

ENTRYPOINT "/entrypoint.sh"

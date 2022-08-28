# docker-wireguard-socks-proxy

Expose WireGuard as a SOCKS5 proxy in a Docker container.

(For the same thing in OpenVPN, see [kizzx2/docker-openvpn-client-socks](https://github.com/kizzx2/docker-openvpn-client-socks))

## Why?

This is arguably the easiest way to achieve "app based" routing. For example, you may only want certain applications to go through your WireGuard tunnel while the rest of your system should go through the default gateway. You can also achieve "domain name based" routing by using a [PAC file](https://developer.mozilla.org/en-US/docs/Web/HTTP/Proxy_servers_and_tunneling/Proxy_Auto-Configuration_(PAC)_file) that most browsers support.

## Usage

### Build the docker

```bash
podman build -t wireguard-socks5:latest-arm .
```

```bash
podman run --rm -d \
    --name=wireguard-socks-proxy \
    --device=/dev/net/tun --cap-add=NET_ADMIN --privileged \
    --publish 127.0.0.1:1080:1080 \
    --volume /my/dir/to/wireguard:/etc/wireguard:z \
    wireguard-socks5:latest-arm
```

Then connect to SOCKS proxy through through `127.0.0.1:1080`. For example:

```bash
curl --proxy socks5h://127.0.0.1:1080 ipinfo.io
```

## HTTP Proxy

You can easily convert this to an HTTP proxy using [http-proxy-to-socks](https://github.com/oyyd/http-proxy-to-socks), e.g.

```bash
hpts -s 127.0.0.1:1080 -p 8080
```

## Troubleshooting

### I get "Permission Denied"

This can happen if your WireGuard configuration file includes an IPv6 address but your host interface does not work with it. Try removing the IPv6 address in `Address` from your configuration file.

### I get "could not resolve hostname "tap0": Name does not resolve."

This means you have a different ethernet interface in the container. You can enter the container and check the real interface name:

```shell
podman run --rm -it --entrypoint /bin/sh --volume /my/dir/to/wireguard:/etc/wireguard:z wireguard-socks5:latest-arm
ifconfig # check your ethernet interface name and modify file `sockd.conf` and rebuild the docker
```
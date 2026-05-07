# Universal Reverse Proxy — Documentation

This add-on is a Home Assistant Ingress reverse proxy for externally hosted web applications.
It does not run upstream applications itself.

## Prerequisites

- Home Assistant host can reach each upstream service directly.
- Each upstream web UI is reachable at a known URL (e.g. `http://192.168.1.50:7070`).

## Configuration

| Option | Required | Description |
|--------|----------|-------------|
| `routes` | yes | List of route mappings in the format `/subpath|http://target-host:port` |

**Example:**

```yaml
routes:
	- /evcc|http://192.168.1.50:7070
	- /router|http://192.168.1.1
```

## How it works

The add-on runs an nginx reverse proxy inside a container.
Home Assistant Ingress forwards requests to the proxy (port 8099).
The proxy routes requests by subpath to the configured upstream URL.
WebSocket connections are forwarded transparently.

Route behavior:

- `/evcc` redirects to `/evcc/`
- `/evcc/*` proxies to `http://.../*`

## Firewall notes

Home Assistant must be able to reach each configured target URL directly.
If upstream systems have firewalls enabled, allow the IP address of your HA host.

## Troubleshooting

- **404 on root**: open a configured subpath (for example `/evcc/`).
- **502 Bad Gateway**: upstream target is not reachable at the configured URL.
- **Container fails to start**: check route format, it must be `/subpath|http://host:port`.

# Home Assistant Add-on: Universal Reverse Proxy

This add-on provides a Home Assistant Ingress reverse proxy for externally hosted web apps.

It does **not** run upstream applications itself. It only proxies them.

## Features

- Multiple uplinks (targets) via subpaths
- Single Ingress entry point
- WebSocket forwarding support
- Compatible with external apps like evcc, router UIs, NAS dashboards, and more

## Configuration format

Configure `routes` as a list of strings:

`/subpath|http://target-host:port`

Example:

```yaml
routes:
	- /evcc|http://192.168.1.50:7070
	- /router|http://192.168.1.1
```

Then add sidebar links to the desired subpaths (for example `/api/hassio_ingress/<ingress_token>/evcc/`).
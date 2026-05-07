# Changelog

## 0.2.3

- Fixed root page route links to work correctly behind Home Assistant Ingress base paths

## 0.2.2

- Fixed startup error by creating the index output directory before writing `index.html`

## 0.2.1

- Added a root landing page that lists all configured route links

## 0.2.0

- Renamed add-on to Universal Reverse Proxy
- Added multi-target routing via configurable subpaths
- Added `routes` option with `/subpath|http://target-host:port` format
- Added runtime validation for route mappings

## 0.1.1

- Initial release of the evcc proxy add-on
- Adds Home Assistant Ingress access to an externally hosted evcc instance
- Uses nginx as a lightweight reverse proxy with WebSocket support
- Marked as experimental for initial user feedback

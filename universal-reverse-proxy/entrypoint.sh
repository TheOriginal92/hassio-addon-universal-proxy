#!/bin/sh
set -eu

OPTIONS_FILE="/data/options.json"
ROUTES_FILE="/etc/nginx/routes.conf"
INDEX_FILE="/usr/share/nginx/html/index.html"

if [ ! -f "$OPTIONS_FILE" ]; then
	echo "Missing options file: $OPTIONS_FILE"
	exit 1
fi

route_count=$(jq -r '.routes | length' "$OPTIONS_FILE" 2>/dev/null || echo "0")

if [ "$route_count" -le 0 ]; then
	echo "No routes configured. Add at least one entry to options.routes (format: /path|http://host:port)."
	exit 1
fi

: > "$ROUTES_FILE"

mkdir -p "$(dirname "$INDEX_FILE")"

cat > "$INDEX_FILE" <<EOF
<!doctype html>
<html>
	<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<title>Universal Reverse Proxy</title>
	</head>
	<body>
		<h1>Universal Reverse Proxy</h1>
		<p>Configured routes:</p>
		<ul>
EOF

jq -r '.routes[]' "$OPTIONS_FILE" | while IFS= read -r route; do
	path="${route%%|*}"
	target_url="${route#*|}"

	if [ "$path" = "$route" ] || [ -z "$path" ] || [ -z "$target_url" ]; then
		echo "Invalid route '$route'. Expected format: /path|http://host:port"
		exit 1
	fi

	case "$path" in
		/*) ;;
		*)
			echo "Invalid path '$path' in route '$route'. Path must start with '/'."
			exit 1
			;;
	esac

	path="$(printf '%s' "$path" | sed 's#/*$##')"

	if [ -z "$path" ] || [ "$path" = "/" ]; then
		echo "Invalid path '$path' in route '$route'. Root path '/' is not allowed."
		exit 1
	fi

	if ! printf '%s' "$path" | grep -Eq '^/[A-Za-z0-9._/-]+$'; then
		echo "Invalid path '$path' in route '$route'. Allowed chars: a-z A-Z 0-9 . _ - /"
		exit 1
	fi

	if ! printf '%s' "$target_url" | grep -Eq '^https?://[^[:space:]]+$'; then
		echo "Invalid target URL '$target_url' in route '$route'."
		exit 1
	fi

	printf '      <li><a href="%s/">%s/</a> → %s</li>\n' "$path" "$path" "$target_url" >> "$INDEX_FILE"

	cat >> "$ROUTES_FILE" <<EOF
				location = ${path} {
						return 302 ${path}/;
				}

				location ${path}/ {
						proxy_pass ${target_url}/;
						sub_filter_once off;
				}

EOF
done

cat >> "$INDEX_FILE" <<EOF
		</ul>
	</body>
</html>
EOF

cp /etc/nginx/nginx.conf.gtpl /etc/nginx/nginx.conf

echo "Starting universal reverse proxy with ${route_count} route(s)"
exec nginx -g 'daemon off;'

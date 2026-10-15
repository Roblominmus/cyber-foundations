#!/usr/bin/env bash
# Build the recon range and start it. Run this, then work the exercises.
#
# It generates fresh random flags on every run, so the answers are never in the
# repo. Do not open the generated/ folder until you have finished, in the same way
# you would not read the answers at the back of the book first.
set -euo pipefail
cd "$(dirname "$0")"
OUT=generated

command -v docker >/dev/null || { echo "docker is required"; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT/web/ftp" "$OUT/web/static" "$OUT/web/internal" \
         "$OUT/web/.well-known" "$OUT/web/.git" "$OUT/portal"

R() { openssl rand -hex 8; }

F_TXT="FLAG{dns_txt_$(R)}"
F_AXFR="FLAG{zone_transfer_$(R)}"
F_COMMENT="FLAG{html_comment_$(R)}"
F_FTP="FLAG{ftp_passwords_$(R)}"
F_INTERNAL="FLAG{internal_notes_$(R)}"
F_JS="FLAG{js_api_key_$(R)}"
F_PORTAL="FLAG{portal_header_$(R)}"

echo "[*] writing flags and content"

# ---------- DNS ----------
cat > "$OUT/zone.recon.lab" <<EOF
\$ORIGIN recon.lab.
\$TTL 300
@	IN	SOA	ns1.recon.lab. admin.recon.lab. (
			2024010101 ; serial
			7200       ; refresh
			3600       ; retry
			1209600    ; expire
			300 )      ; minimum
@		IN	NS	ns1.recon.lab.
@		IN	MX	10 mail.recon.lab.
@		IN	TXT	"v=recon-lab; flag=$F_TXT"
ns1		IN	A	172.28.0.53
mail		IN	A	172.28.0.53
www		IN	A	172.28.0.10
dev		IN	A	172.28.0.10
portal		IN	A	172.28.0.10
legacy-backup	IN	TXT	"$F_AXFR"
EOF

cat > "$OUT/Corefile" <<'EOF'
recon.lab:53 {
    file /zones/zone.recon.lab
    transfer {
        to *
    }
    log
    errors
}
EOF

# ---------- nginx ----------
cat > "$OUT/nginx.conf" <<EOF
server {
    listen 80 default_server;
    server_name _;
    server_tokens on;
    return 404;
}

server {
    listen 80;
    server_name www.recon.lab dev.recon.lab;

    root /usr/share/nginx/html;
    index index.html;
    server_tokens on;
    autoindex on;

    add_header X-Powered-By "ReconLab/1.4.2" always;

    location / {
        try_files \$uri \$uri/ =404;
    }
}

server {
    listen 80;
    server_name portal.recon.lab;

    root /usr/share/nginx/html-portal;
    index index.html;
    server_tokens on;

    add_header X-Build-Token "$F_PORTAL" always;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF

# ---------- the main site ----------
cat > "$OUT/web/index.html" <<'EOF'
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>ReconLab</title>
<link rel="stylesheet" href="/static/style.css"></head>
<body>
<h1>ReconLab</h1>
<p>A deliberately messy web server for practising recon.</p>
<ul>
  <li><a href="/about.html">About</a></li>
  <li><a href="/static/app.js">Application</a></li>
</ul>
</body>
</html>
EOF

cat > "$OUT/web/about.html" <<EOF
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><title>About ReconLab</title></head>
<body>
<h1>About</h1>
<p>ReconLab is a small internal project. Nothing here is real.</p>
<!-- TODO: remove the old staff list before launch. Note for the audit: $F_COMMENT -->
</body>
</html>
EOF

cat > "$OUT/web/static/style.css" <<'EOF'
body { font-family: sans-serif; margin: 4rem; }
EOF

cat > "$OUT/web/static/app.js" <<EOF
const API_BASE = "/api/v2";
const endpoints = ["/api/v2/users", "/api/v2/orders", "/api/v2/admin/audit"];

// legacy key, rotate before the next release
const API_KEY = "$F_JS";

function listUsers() { return fetch(API_BASE + "/users"); }
EOF

cat > "$OUT/web/.well-known/security.txt" <<'EOF'
Contact: mailto:security@recon.lab
Expires: 2030-01-01T00:00:00.000Z
Policy: https://recon.lab/security-policy
EOF

cat > "$OUT/web/.git/HEAD" <<'EOF'
ref: refs/heads/main
EOF

cat > "$OUT/web/sitemap.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>http://www.recon.lab/</loc></url>
  <url><loc>http://www.recon.lab/about.html</loc></url>
</urlset>
EOF

cat > "$OUT/web/robots.txt" <<'EOF'
User-agent: *
Disallow: /ftp/
Disallow: /internal/
Disallow: /backup/
Allow: /

Sitemap: http://www.recon.lab/sitemap.xml
EOF

# ---------- the things that should not be public ----------
cat > "$OUT/web/ftp/staff-passwords.txt" <<EOF
ReconLab staff portal, temporary passwords, change on first login.

j.okoro      Autumn2026!
s.mendes     $F_FTP
r.patel      Winter2026!
EOF

cat > "$OUT/web/ftp/notes.txt" <<'EOF'
Backup runs nightly at 02:00. See /backup/ for the archives.
EOF

cat > "$OUT/web/internal/notes.html" <<EOF
<!doctype html>
<html><head><title>Internal notes</title></head>
<body>
<h1>Internal notes</h1>
<p>Staging migrations are still pointing at the old host.</p>
<p>Audit reference: $F_INTERNAL</p>
</body></html>
EOF

cat > "$OUT/portal/index.html" <<'EOF'
<!doctype html>
<html><head><title>Staff portal</title></head>
<body><h1>Staff portal</h1><p>Sign in to continue.</p></body></html>
EOF

chmod -R a+rX "$OUT"

echo "[*] starting containers"
docker compose up -d

echo
echo "Range is up."
echo "  DNS   dig @127.0.0.1 -p 15353 recon.lab ANY"
echo "  Web   curl -s http://127.0.0.1:8080/"
echo
echo "There are 7 flags. Find them with the techniques, not by reading $OUT/."

#!/bin/sh
# Runs inside a throwaway alpine container as the "init" service.
# Writes the DNS zone and the website into /out with fresh random flags.
# The host needs nothing but Docker: no bash, no python, no chmod.
set -eu

OUT=/out
# /out is a mount point, so clear its contents rather than the directory itself
find "$OUT" -mindepth 1 -exec rm -rf {} + 2>/dev/null || true
mkdir -p "$OUT/web/ftp" "$OUT/web/static" "$OUT/web/internal" \
         "$OUT/web/.well-known" "$OUT/web/.git" "$OUT/web/public" "$OUT/portal"

R() { head -c 6 /dev/urandom | od -An -tx1 | tr -d ' \n'; }

F_TXT="FLAG{dns_txt_$(R)}"
F_AXFR="FLAG{zone_transfer_$(R)}"
F_COMMENT="FLAG{html_comment_$(R)}"
F_FTP="FLAG{ftp_passwords_$(R)}"
F_INTERNAL="FLAG{internal_notes_$(R)}"
F_JS="FLAG{js_api_key_$(R)}"
F_PORTAL="FLAG{portal_header_$(R)}"
F_GIT="FLAG{git_remote_$(R)}"

# ---------------- DNS ----------------
cat > "$OUT/zone.recon.lab" <<EOF
\$ORIGIN recon.lab.
\$TTL 300
@		IN	SOA	ns1.recon.lab. admin.recon.lab. (
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
    file /zone/zone.recon.lab
    transfer {
        to *
    }
    log
    errors
}
EOF

# ---------------- nginx ----------------
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

# ---------------- site ----------------
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
  <li><a href="/public/annual-report.pdf">Annual report</a></li>
  <li><a href="/static/app.js">Application</a></li>
</ul>
<p>General enquiries: info@recon.lab</p>
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
<p>Team: j.okoro@recon.lab, s.mendes@recon.lab, r.patel@recon.lab</p>
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

cat > "$OUT/web/.git/config" <<EOF
[core]
	repositoryformatversion = 0
	filemode = true
[remote "origin"]
	url = https://deploy:$F_GIT@git.recon.lab/reconlab/site.git
	fetch = +refs/heads/*:refs/remotes/origin/*
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

# ---------------- things that should not be public ----------------
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

cp /assets/annual-report.pdf "$OUT/web/public/annual-report.pdf"

cat > "$OUT/portal/index.html" <<'EOF'
<!doctype html>
<html><head><title>Staff portal</title></head>
<body><h1>Staff portal</h1><p>Sign in to continue.</p></body></html>
EOF

chmod -R a+rX "$OUT"
echo "generated 8 flags into $OUT"

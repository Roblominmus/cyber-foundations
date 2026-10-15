# 08: Automating recon

[Previous: Web archives](07-web-archives.md) | [Session index](README.md) | [Next: Skills assessment](09-skills-assessment.md)

## Why automate

By now you have done each step by hand. Automation is not a different skill, it is
the same steps in a script so that you can run them against a bigger target, and
run them again next week without starting over.

Automate last, not first. If you automate something you do not understand, you get
a big output file you cannot read and a report you cannot defend.

## The pipeline

The standard chain, in order. Each stage eats the previous stage's output.

```
names      subfinder, crt.sh        ->  a list of hostnames
   |
alive      httpx                    ->  which ones actually respond, with headers
   |
content    katana, ffuf             ->  URLs, directories, parameters
   |
screens    eyewitness, aquatone     ->  a visual index of what you found
   |
issues     nuclei                   ->  known misconfigurations and exposures
```

The last stage, `nuclei`, is the one people reach for first. Do not. It is a
scanner, and a scanner on an unverified host list produces noise. Do the first
three stages, then run `nuclei` on hosts you have confirmed are alive and in scope.

## A worked script

```bash
#!/usr/bin/env bash
# recon.sh <domain>   run from an empty folder
set -euo pipefail
D="$1"; mkdir -p "$D"; cd "$D"

echo "[*] subdomains"
subfinder -d "$D" -silent | sort -u > subs.txt
curl -s "https://crt.sh/?q=%25.$D&output=json" \
  | python3 -c "import sys,json;[print(n) for e in json.load(sys.stdin) for n in e['name_value'].split('\n')]" \
  | sed 's/\*\.//' | sort -u >> subs.txt
sort -u subs.txt -o subs.txt
wc -l subs.txt

echo "[*] which are alive"
httpx -l subs.txt -silent -status-code -title -tech-detect -o alive.txt
cat alive.txt

echo "[*] crawl what is alive"
awk '{print $1}' alive.txt | while read -r u; do
  katana -u "$u" -d 2 -jc -silent 2>/dev/null || true
done | sort -u > urls.txt
wc -l urls.txt

echo "[*] interesting shapes"
grep -iE 'admin|login|api|upload|backup|\.zip|\.sql|\.bak|\.env|config' urls.txt > interesting.txt || true
cat interesting.txt

echo "[*] done. Read alive.txt and interesting.txt by hand."
```

Run it as `bash recon.sh example.com`. Read the output by hand. The script's job is
to remove the typing, not the thinking.

## Rules that keep you out of trouble

- **Scope first.** Confirm every host in your list is in scope. A subdomain you
  found by certificate transparency may be owned by a third party, and scanning it
  could be an offence.
- **Rate limit.** `ffuf` and `nuclei` will happily send thousands of requests a
  second. Add `-rate-limit` and `-t` limits. Overloading a client's site is a real
  way to end an engagement badly.
- **Not everything wants to be scanned.** Some hosts are production, some are
  fragile legacy systems. If in doubt, ask.
- **Keep the raw output.** Every finding must be traceable to a command and a
  timestamp. Store the tool output next to your notes.

## Store the results properly

```
example.com/
  subs.txt          raw subdomain list
  alive.txt         httpx output
  urls.txt          crawled URLs
  interesting.txt   filtered for review
  notes.md          your written findings, with dates
  evidence/         screenshots
```

Six months later, on the next engagement, that folder is worth more than the
tools.

## Practise

### Task: automate the range end to end

The range has eight flags. Do not look for them by hand this time. Write the
pipeline, let it find them, then verify only what it reports.

Target details:

- DNS on `127.0.0.1:15353`, zone `recon.lab`
- Web on `127.0.0.1:8080`, with `Host` headers for the vhosts
- The wordlist is `recon-range/wordlist.txt`

Subfinder and httpx expect real DNS and real hostnames, so against a lab you swap
those stages for `dig` and `curl`. The stages are what matter, not the brands.

**Linux or macOS version:**

```bash
#!/usr/bin/env bash
set -uo pipefail
WL=recon-range/wordlist.txt

echo "[*] zone dump"
dig @127.0.0.1 -p 15353 AXFR recon.lab | tee zone.txt

echo "[*] names that resolve"
while read -r w; do
  dig +short @127.0.0.1 -p 15353 "$w.recon.lab" A | grep -q . && echo "$w.recon.lab"
done < "$WL" | sort -u | tee names.txt

echo "[*] vhosts and headers"
while read -r h; do
  code=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: $h.recon.lab" http://127.0.0.1:8080/)
  [ "$code" = "200" ] && echo "$h.recon.lab" && curl -s -D - -o /dev/null -H "Host: $h.recon.lab" http://127.0.0.1:8080/
done < "$WL" | tee vhosts.txt

echo "[*] content that is not a 404"
for p in /robots.txt /sitemap.xml /.well-known/security.txt /.git/HEAD /.git/config \
         /ftp/ /ftp/staff-passwords.txt /internal/notes.html /static/app.js \
         /public/annual-report.pdf /backup/; do
  code=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: www.recon.lab" "http://127.0.0.1:8080$p")
  [ "$code" != "404" ] && echo "$code  $p"
done | tee content.txt

echo "[*] flags seen"
grep -rho "FLAG{[^}]*}" . | sort -u
```

**Windows PowerShell version:**

```powershell
$wl   = "recon-range\wordlist.txt"
$base = "http://127.0.0.1:8080"

"--- zone dump"
docker compose run --rm tools @dns AXFR recon.lab | Tee-Object zone.txt

"--- names that resolve"
Get-Content $wl | ForEach-Object {
  $r = Resolve-DnsName -Server 127.0.0.1 -Port 15353 -Type A "$_.recon.lab" -ErrorAction SilentlyContinue
  if ($r) { "$_.recon.lab" }
} | Sort-Object -Unique | Tee-Object names.txt

"--- vhosts"
Get-Content $wl | ForEach-Object {
  $c = curl.exe -s -o NUL -w "%{http_code}" -H "Host: $_.recon.lab" "$base/"
  if ($c -eq "200") { "$_.recon.lab" }
} | Sort-Object -Unique

"--- content that is not a 404"
$paths = "/robots.txt","/sitemap.xml","/.well-known/security.txt","/.git/HEAD",
         "/.git/config","/ftp/","/ftp/staff-passwords.txt","/internal/notes.html",
         "/static/app.js","/public/annual-report.pdf","/backup/"
foreach ($p in $paths) {
  $c = curl.exe -s -o NUL -w "%{http_code}" -H "Host: www.recon.lab" "$base$p"
  if ($c -ne "404") { "{0}  {1}" -f $c, $p }
} | Tee-Object content.txt

"--- flags seen"
Select-String -Path .\*.txt -Pattern "FLAG{[^}]*}" -AllMatches |
  ForEach-Object { $_.Matches.Value } | Sort-Object -Unique
```

### Deliverable

Save it as `recon-range.sh` or `recon-range.ps1`, then answer:

1. How many of the eight flags did your script find without you touching it?
2. For each one it missed, why did it miss it, and what would you add?
3. Which stage produced the most findings?
4. Why should `nuclei` still not be the first stage, even on your own range?
5. Your script printed a lot of noise. Which filter removed the most of it?

### Room task

**[TryHackMe: ffuf](https://tryhackme.com/room/ffuf)** (free) covers the content
discovery stage properly, including how to filter output so it is readable.

**Questions for your notes:**

- Why is the order names, then alive, then content, and not the reverse?
- What breaks if you point this at a domain you do not control?
- Which part of the run would you still want a human to look at?

[Previous: Web archives](07-web-archives.md) | [Session index](README.md) | [Next: Skills assessment](09-skills-assessment.md)

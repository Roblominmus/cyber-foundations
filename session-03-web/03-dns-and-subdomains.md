# 03: DNS and subdomains

[Previous: WHOIS and email addresses](02-whois.md) | [Session index](README.md) | [Next: Fingerprinting](04-fingerprinting.md)

## Why DNS matters more than it looks

DNS is the map of everything a company runs. The main website is one record. The
interesting things are in the others: the staging server, the VPN, the mail
gateway, the old app nobody remembers. Subdomain enumeration is usually the
single highest value activity in web recon.

## Record types you need to know

| Type | Means | Why you care |
|---|---|---|
| `A` | Name to IPv4 address | The actual hosts |
| `AAAA` | Name to IPv6 address | Often forgotten, sometimes exposes a host the A record hides |
| `CNAME` | Alias to another name | Reveals third party services and takeover chances |
| `MX` | Mail servers | Reveals the mail provider, and sometimes the internal naming |
| `NS` | Name servers | Who runs DNS for the domain |
| `TXT` | Free text | SPF, verification tokens, and sometimes secrets |
| `SOA` | Zone authority | Primary name server and admin contact |
| `SRV` | Service location | Common in Microsoft environments, can leak internal names |
| `PTR` | Reverse, IP to name | Confirms what a host thinks it is |

## The commands

```bash
# everything for one name
dig example.com ANY

# be specific, this is what you usually want
dig +short example.com A
dig +short example.com MX
dig +short example.com NS
dig +short example.com TXT

# ask a specific resolver
dig @1.1.1.1 example.com A

# the same with the older tool
nslookup -type=MX example.com
host -t txt example.com
```

Read the `ANSWER SECTION` in full `dig` output. The `+short` form is faster but
hides the record types.

## Zone transfers, and why they are the dream

A zone transfer (`AXFR`) is how a secondary name server copies an entire zone from
the primary. When a server has not restricted who can ask, it will hand the whole
list of names to anyone. That turns subdomain enumeration from guessing into
reading.

```bash
# find a name server first
dig +short example.com NS

# then ask it for the whole zone
dig axfr @ns1.example.com example.com
```

Most public servers refuse this now, which is correct. When it works, note it as
a finding, because it is a real misconfiguration. It is common on internal
assessments and on lab machines.

## Subdomain enumeration

Four methods worth knowing. Use them together, because each finds names the
others miss.

**1. Certificate transparency logs.** Every TLS certificate issued for a domain
is logged publicly. That log is a list of names, including ones the company never
meant to publish.

- Browse it at [crt.sh](https://crt.sh). Search `%.example.com` and read the
  results.
- From the command line:

```bash
curl -s "https://crt.sh/?q=%25.example.com&output=json" | \
  python3 -c "import sys,json;[print(e['name_value']) for e in json.load(sys.stdin)]" | \
  tr '\n' '\n' | sort -u
```

**2. Brute force with a wordlist.** Guess names from a list of common prefixes.

```bash
ffuf -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
     -u https://FUZZ.example.com -mc 200,301,302,403
```

**3. Tools that use many sources at once.** `subfinder` collects from certificate
logs, passive DNS and other public sources.

```bash
subfinder -d example.com -silent | sort -u > subs.txt
```

**4. DNS aggregation sites.** [DNSDumpster](https://dnsdumpster.com) shows a
domain's hosts, and draws the relationships. Good for a quick picture.

Then probe the list to see which names actually serve something, and grab their
titles and headers in one pass:

```bash
httpx -l subs.txt -title -status-code -tech-detect
```

## Subdomains are not virtual hosts

These are different things and this trips people up.

- **Subdomain**: a DNS name that resolves, like `dev.example.com`.
- **Virtual host**: several websites served by one IP, told apart by the `Host`
  header. There may be no DNS record at all.

If you find an IP with a web server, you should always try vhost fuzzing, because
a site can exist there with no public DNS name pointing at it:

```bash
ffuf -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt \
     -u http://203.0.113.10 -H "Host: FUZZ.example.com" -fs 4242
```

The `-fs` flag filters out the response size of the default site, so you only see
the ones that differ. Without it the output is unreadable.

## Practise

### Task 1: DNS records, flag 1

Start the range. Everything here works on all three systems; pick your row.

**Linux or macOS, with dig:**

```bash
dig @127.0.0.1 -p 15353 recon.lab ANY
dig +short @127.0.0.1 -p 15353 recon.lab MX
dig +short @127.0.0.1 -p 15353 recon.lab NS
dig +short @127.0.0.1 -p 15353 recon.lab TXT
```

**Windows, with nslookup (already installed):**

```powershell
nslookup -port=15353 -type=any recon.lab 127.0.0.1
nslookup -port=15353 -type=mx  recon.lab 127.0.0.1
nslookup -port=15353 -type=txt recon.lab 127.0.0.1
nslookup -port=15353 -type=ns  recon.lab 127.0.0.1
```

**Any system, using the tools container, which is the same dig everywhere:**

```bash
docker compose run --rm tools @dns recon.lab ANY
```

1. **Flag 1** is in the TXT record on the zone. Write it down with the command
   that produced it.
2. List every record type the zone holds and what each one tells you.

### Task 2: zone transfer, flag 2

A zone transfer asks a name server for every record it holds. When a server does
not restrict who can ask, you get the whole map at once.

```bash
# Linux or macOS
dig @127.0.0.1 -p 15353 AXFR recon.lab

# any system, including Windows
docker compose run --rm tools @dns AXFR recon.lab
```

3. **Flag 2** is in the TXT record of a name that no wordlist will guess. Find it
   in the dump.
4. Count every name the transfer gave you. Now count how many of them a wordlist
   would have found. Write both numbers down, because the gap between them is the
   whole argument for trying AXFR first.
5. On a real target this usually fails with `Transfer failed`. That is the correct
   answer, and it is worth recording as "checked, refused".

### Task 3: subdomain enumeration, and why brute force loses

The range ships its own wordlist, so this needs no Kali paths.

**Linux or macOS:**

```bash
while read -r w; do
  dig +short @127.0.0.1 -p 15353 "$w.recon.lab" A | grep -q . && echo "found: $w.recon.lab"
done < recon-range/wordlist.txt
```

**Windows PowerShell:**

```powershell
Get-Content recon-range\wordlist.txt | ForEach-Object {
  $r = Resolve-DnsName -Server 127.0.0.1 -Port 15353 -Type A "$_.recon.lab" -ErrorAction SilentlyContinue
  if ($r) { "found: $_.recon.lab" }
}
```

**Any system, naming one host at a time through the tools container, which is the
same dig everywhere:**

```bash
docker compose run --rm tools @dns portal.recon.lab A
docker compose run --rm tools @dns www.recon.lab A
```

6. Which names did brute force find?
7. Which names did it miss that the zone transfer handed you?
8. Explain, in one sentence, why brute force can never be complete.

### Task 4: certificate transparency, in a browser

This one cannot be faked locally, because it needs the real certificate log. It
needs no tools, so it works on any system.

1. Open [crt.sh](https://crt.sh).
2. Search for `%.` followed by a domain you are allowed to look at, for example
   `%.example.com`.
3. From the results, list every unique name.
4. Compare that list with what subdomain brute force would plausibly find.
5. Answer: why does this work at all? What is it about certificates that makes
   every name public?

The room's version of this, with its own answers, is in
[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)
(free).

### Task 5: subdomain is not virtual host

The web server decides which site to serve from the `Host` header alone, with no
DNS involved. That is how one IP hosts many sites.

```bash
curl -s -o /dev/null -w "%{http_code}\n" -H "Host: www.recon.lab"    http://127.0.0.1:8080/
curl -s -o /dev/null -w "%{http_code}\n" -H "Host: portal.recon.lab" http://127.0.0.1:8080/
curl -s -o /dev/null -w "%{http_code}\n" -H "Host: nope.recon.lab"   http://127.0.0.1:8080/
```

6. The third one returns 404 while the first two return 200. Why does that
   difference matter for finding virtual hosts?
7. On Windows, if `curl` does not behave, use `curl.exe` in the same command.

You will finish this on page 04, because the hidden vhost holds flag 7.

### Room task and real world table

**[TryHackMe: DNS in Detail](https://tryhackme.com/room/dnsindetail)** (free) for
every record type with questions.

Against a real domain you are allowed to investigate:

| What | Your answer |
|---|---|
| A record for the apex | |
| MX, and the provider it implies | |
| NS, and who runs them | |
| Anything interesting in TXT | |
| Names from certificate transparency | |
| Names from the range wordlist method | |
| Which source found more, and why | |
| Did a zone transfer work, and should it have | |

**Questions for your notes:**

- Why did the zone transfer give you names that brute force missed?
- Why does `nope.recon.lab` returning 404 matter for vhost fuzzing?
- What is the difference between a subdomain and a virtual host?

[Previous: WHOIS and email addresses](02-whois.md) | [Session index](README.md) | [Next: Fingerprinting](04-fingerprinting.md)

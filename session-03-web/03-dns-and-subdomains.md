# 03: DNS and subdomains

[Previous: WHOIS](02-whois.md) | [Session index](README.md) | [Next: Fingerprinting](04-fingerprinting.md)

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

### On the range: DNS records, flag 1 and flag 2

Start the range first: `cd recon-range && ./up.sh`. The DNS server answers on port
15353, so every query needs `-p 15353`.

```bash
# the whole zone in one go
dig @127.0.0.1 -p 15353 recon.lab ANY

# or one type at a time
dig +short @127.0.0.1 -p 15353 recon.lab MX
dig +short @127.0.0.1 -p 15353 recon.lab NS
dig +short @127.0.0.1 -p 15353 recon.lab TXT
```

1. **Flag 1** is in the TXT record on the zone. Read it and write it down.
2. The zone also holds a name that no wordlist will guess. Stop guessing and ask
   for everything:

```bash
dig @127.0.0.1 -p 15353 AXFR recon.lab
```

3. **Flag 2** is in the TXT record of that hidden name. Notice what just happened:
   one query returned every record in the zone, including names you could not have
   guessed. That is exactly why an open zone transfer is a finding, not a
   convenience.
4. Count the names the transfer gave you, then count how many of them a wordlist
   would have found. Write both numbers down.

### On the range: subdomains against the DNS

```bash
# the names that resolve
for n in www dev portal mail ns1 legacy-backup; do
  printf '%-16s ' "$n"; dig +short @127.0.0.1 -p 15353 "$n.recon.lab" A
done

# brute force, small list, this is slow on purpose
head -200 /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt | \
while read -r w; do
  dig +short @127.0.0.1 -p 15353 "$w.recon.lab" A | grep -q . && echo "found: $w.recon.lab"
done
```

Compare what brute force found with what the zone transfer found. The gap between
those two lists is the whole argument for checking AXFR first.

### On the range: subdomain is not virtual host

`portal` resolves in DNS, but the web server decides which site to serve from the
`Host` header alone, with no DNS involved:

```bash
curl -s -o /dev/null -w '%{http_code}\n' -H "Host: www.recon.lab"    http://127.0.0.1:8080/
curl -s -o /dev/null -w '%{http_code}\n' -H "Host: portal.recon.lab" http://127.0.0.1:8080/
curl -s -o /dev/null -w '%{http_code}\n' -H "Host: nope.recon.lab"   http://127.0.0.1:8080/
```

The third one returns 404 while the first two return 200. That baseline is what
makes vhost fuzzing possible, and it is how you will find flag 7 on the next page.

### Room tasks

- **[TryHackMe: DNS in Detail](https://tryhackme.com/room/dnsindetail)** (free).
  Every record type, with questions about each. Do this one first, it is the
  foundation for everything else here.
- The DNS and certificate transparency tasks in
  **[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)**
  (free). The same techniques against a real domain, with the room's own answers.
  Certificate transparency is the part the range cannot teach you, because it needs
  a real certificate log.

### Real world task

Against a domain you are allowed to investigate. Fill in the table, do not write
an essay:

| What | Your answer |
|---|---|
| A record for the apex | |
| MX, and which mail provider it implies | |
| NS, and who runs them | |
| Anything interesting in the TXT records | |
| Names found via certificate transparency | |
| Names found via subfinder | |
| Which source found more, and why | |
| Did a zone transfer work, and should it have | |

**Questions to answer in your notes:**

- Why did the zone transfer give you names that brute force missed?
- Why does `nope.recon.lab` returning 404 matter for vhost fuzzing?
- What is the difference between a subdomain and a virtual host?
- Which record type would you check first to find a company's mail provider?

[Previous: WHOIS](02-whois.md) | [Session index](README.md) | [Next: Fingerprinting](04-fingerprinting.md)

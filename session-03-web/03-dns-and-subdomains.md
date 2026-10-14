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

**Room task 1.** [TryHackMe: DNS in Detail](https://tryhackme.com/room/dnsindetail)
(free). This room walks every record type and asks questions about them. Do it
before the rest, it is the foundation.

**Room task 2.** The DNS and certificate transparency tasks in
[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)
(free). The room uses DNSDumpster and certificate logs against a target and asks
for specific findings.

**Real world task.** For a domain you are allowed to investigate:

1. List every `A`, `MX`, `NS` and `TXT` record. Note anything interesting in TXT,
   such as SPF records or verification tokens.
2. Pull the certificate transparency log for `%.that-domain` and collect every
   unique name. How many did you get that are not the main site?
3. Run `subfinder` against it and compare with the certificate list. Which found
   more, and why?
4. Probe everything with `httpx` and note any that answer with a login page, a
   directory listing, or a non production looking name.
5. Try a zone transfer against each name server. Record whether it is refused.
   A refusal is the correct answer and worth noting as such.

**Questions to answer in your notes:**

- What is the difference between a subdomain and a virtual host, and why does the
  distinction change how you enumerate?
- Why are certificate transparency logs so effective at finding subdomains that
  brute force misses?
- Which record type would you check first to find a company's mail provider?

[Previous: WHOIS](02-whois.md) | [Session index](README.md) | [Next: Fingerprinting](04-fingerprinting.md)

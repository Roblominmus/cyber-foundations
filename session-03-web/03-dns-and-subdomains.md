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

Everything on this page can be done in a browser. Terminal commands are optional
extras for those who have them.

### Task 1: DNS records, in a browser

Open [viewdns.info](https://viewdns.info/) or
[dnsdumpster.com](https://dnsdumpster.com/), and look up a domain you are allowed
to investigate. Record every record type it shows you.

For each one, write down what it tells you:

| Type | What it tells you | Your target's value |
|---|---|---|
| A | The IPv4 address of a host | |
| AAAA | The IPv6 address, often forgotten | |
| CNAME | An alias, which can reveal a third party service | |
| MX | The mail provider | |
| NS | Who runs the DNS | |
| TXT | SPF, verification tokens, sometimes secrets | |

**If you have a terminal**, the same thing from the command line. On Windows use
`nslookup`, which is already installed. On macOS and Linux use either.

```powershell
# Windows
nslookup -type=mx example.com
nslookup -type=txt example.com
nslookup -type=ns example.com
```

```bash
# macOS and Linux
dig +short example.com MX
dig +short example.com TXT
dig +short example.com NS
```

### Task 2: certificate transparency, in a browser

This is the single most effective passive subdomain technique, and it needs no
tools at all.

1. Open [crt.sh](https://crt.sh).
2. Search for `%.` followed by your domain, for example `%.example.com`.
3. From the results, list every unique name.
4. How many of those names are not the main website?
5. Answer: why does this work? What is it about TLS certificates that makes every
   name they cover public?

Every certificate authority logs every certificate it issues. That log is public
on purpose, which is why it is such a good source for subdomains.

### Task 3: subdomains against the room

The guided version, with real answers, is in
**[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)**
(free). It uses DNSDumpster and the certificate logs against a target and asks you
for specific findings.

For the record types themselves, with questions on each,
**[TryHackMe: DNS in Detail](https://tryhackme.com/room/dnsindetail)** (free) is
the room for this page.

### Task 4: zone transfers, and the honest answer

A zone transfer asks a name server for every record it holds. If it is not
restricted, you get the whole map at once. This is worth trying, and it is worth
knowing that it almost always fails.

```bash
dig axfr @ns1.example.com example.com
```

1. Try it against a domain you are allowed to test.
2. Record the result. `Transfer failed` is the correct and expected answer on a
   well configured server, and "checked, refused" belongs in your notes.
3. Explain why an open zone transfer would be a serious finding.

Windows has no `dig`. If you want to try this, the room above covers it.

### Task 5: subdomain versus virtual host

These are different things and people mix them up.

- A **subdomain** is a DNS name that resolves, like `dev.example.com`.
- A **virtual host** is a site served by an IP based only on the `Host` header in
  the request. There may be no DNS record for it at all.

Answer:

1. Why can a virtual host exist with no DNS record?
2. Which one does a browser use to decide what to show you?
3. Why does finding virtual hosts matter if you already have the subdomain list?

Aggressive vhost fuzzing belongs on a target you are authorised to test, so do it
in the **[ffuf room](https://tryhackme.com/room/ffuf)** (free) rather than against
a shared public host.

### Real world table

Against a domain you are allowed to investigate:

| What | Your answer |
|---|---|
| A record for the apex | |
| MX, and the provider it implies | |
| NS, and who runs them | |
| Anything interesting in TXT | |
| Names from certificate transparency | |
| Did a zone transfer work, and should it have | |

**Questions for your notes:**

- Why is certificate transparency so effective at finding subdomains?
- Why does a refused zone transfer still belong in your notes?
- What is the difference between a subdomain and a virtual host?

[Previous: WHOIS and email addresses](02-whois.md) | [Session index](README.md) | [Next: Fingerprinting](04-fingerprinting.md)

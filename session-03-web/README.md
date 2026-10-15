# Session 03: web recon

How to find out what a target is made of before you touch it: what to look for,
where to look, and where to practise.

## Where you practise

The graded practice is the free rooms and the free labs. They have their own
targets and real answers, so you can tell whether you got it right.

| Resource | Covers | Pages |
|---|---|---|
| [Passive Reconnaissance](https://tryhackme.com/room/passiverecon) | WHOIS, DNS, certificate transparency, Shodan, dorks | 02, 03, 06, 07 |
| [Active Reconnaissance](https://tryhackme.com/room/activerecon) | Ping, traceroute, netcat, curl, headers | 04 |
| [DNS in Detail](https://tryhackme.com/room/dnsindetail) | Every DNS record type | 03 |
| [Search Skills](https://tryhackme.com/room/searchskills) | Search engines and dorking | 06 |
| [ffuf](https://tryhackme.com/room/ffuf) | Content discovery, with a hidden `/ftp` find | 05 |
| [PortSwigger: Information disclosure](https://portswigger.net/web-security/information-disclosure) | Leaks through errors, robots.txt and backup files | 05 |

For WHOIS, DNS, certificate transparency, dorks and archives, you read a domain
you are allowed to look at. Those techniques are passive, so reading is the
practice.

## Nothing to install

Every page has a browser path. Terminal commands are optional extras that use
tools the operating system already has:

| Tool | Where it already exists |
|---|---|
| `curl` | Windows 10 and later, macOS, Linux |
| `nslookup` | Windows, macOS, Linux |
| `dig` | macOS and Linux. Windows users use `nslookup` or a browser DNS tool |
| Browser developer tools | Every browser |

## Read in order

| # | Page | What it covers |
|---|---|---|
| 01 | [Recon basics](01-recon-basics.md) | Passive versus active, what you are looking for, the workflow, and the practice plan |
| 02 | [WHOIS and email addresses](02-whois.md) | Registrant data, and harvesting addresses |
| 03 | [DNS and subdomains](03-dns-and-subdomains.md) | Record types, certificate transparency, subdomain enumeration, vhosts |
| 04 | [Fingerprinting](04-fingerprinting.md) | Headers, banners, spotting the tech stack and versions |
| 05 | [Crawling](05-crawling.md) | robots.txt, sitemaps, well-known files, source, JavaScript |
| 06 | [Search engine discovery](06-search-engine-discovery.md) | Dorks, and what they turn up |
| 07 | [Web archives](07-web-archives.md) | The Wayback Machine as a source of removed endpoints and old secrets |
| 08 | [Automating recon](08-automating-recon.md) | Chaining the steps, and the order they go in |
| 09 | [OWASP Top 10 to PortSwigger](09-owasp-top-10-to-portswigger.md) | The list: which Top 10 categories have labs, and where |

## Where the graded practice is

The rooms and the labs have their own targets and real answers, so you can tell
whether you got it right, and somebody else maintains the target.

| Resource | Covers | Pages |
|---|---|---|
| [Passive Reconnaissance](https://tryhackme.com/room/passiverecon) | WHOIS, DNS, certificate transparency, Shodan, dorks | 02, 03, 06, 07 |
| [Active Reconnaissance](https://tryhackme.com/room/activerecon) | Ping, traceroute, netcat, curl, headers | 04 |
| [DNS in Detail](https://tryhackme.com/room/dnsindetail) | Every DNS record type | 03 |
| [Search Skills](https://tryhackme.com/room/searchskills) | Search engines and dorking | 06 |
| [ffuf](https://tryhackme.com/room/ffuf) | Content discovery, with a hidden `/ftp` find | 05 |
| [PortSwigger: Information disclosure](https://portswigger.net/web-security/information-disclosure) | Leaks through errors, robots.txt and backup files | 05 |

The techniques that only exist on the real internet, WHOIS, DNS, certificate
transparency, dorks and archives, are practised by reading any domain you are
allowed to look at. Those techniques are passive by nature, so reading is the
practice.

## Ground rules, do not skip this

Recon against a system you do not own and have no written permission to test is
not practice, it is an offence in most places. Reading `robots.txt`, WHOIS, DNS
records, certificate logs and page source on a public site is passive and normally
fine. Guessing paths, brute forcing and zone transfers are not, unless the target
is yours or is a room built for it. That is why the second kind lives in the rooms
above and nowhere else.

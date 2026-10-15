# Session 03: web recon

Our own version of Hack The Box Academy's "Information Gathering - Web Edition".
HTB teaches it well but it costs cubes, so the same ground is written out here.

## There is no hosted lab, and that is deliberate

It is worth knowing why, because the reason is structural.

HTB's own version of this module splits its assessment in two:

- The WHOIS question runs against a **real public domain** they own, so students
  query live registries and read a real IANA ID.
- The other questions run against a **container on a lab network**, reached
  through the students' hosts file, because that is where you can plant a hidden
  directory, an exposed API key and a deliberately messy site.

Nobody, including HTB, does the whole thing against one free public target. A real
domain has WHOIS, real DNS and certificate transparency, but you cannot plant
leaks in it and its content changes. A lab container has everything planted, but
it has no WHOIS and no certificate log, because it is not a real domain.

So instead of inventing a target that satisfies neither, this module is split the
same way, using only things that already exist:

| Half | Where you practise | What it covers |
|---|---|---|
| Real internet, passive | The free rooms, and any domain you are allowed to look at | WHOIS, DNS, certificate transparency, search engines, archives |
| Web content | The free rooms and the free labs | robots.txt, crawling, source, JavaScript, content discovery |

## Nothing to install

Every page has a browser path. No Docker, no Kali, no Python. Terminal commands
are optional extras that use tools the operating system already has:

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

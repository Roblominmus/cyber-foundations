# Session 03: web recon

Our own version of Hack The Box Academy's "Information Gathering - Web Edition".
HTB teaches it well but it costs cubes, so the same ground is written out here and
every technique is paired with a free place to practise it.

## There is nothing to install

Every technique on every page can be done **in a browser**. No Docker, no Kali, no
Python, no bash. That means it works on Windows, macOS and Linux, and it works if
you are reading this on GitHub with nothing but the page open.

Where a command line genuinely helps, the command is given as an optional extra,
and it uses tools that already ship with the system:

| Tool | Where it already exists |
|---|---|
| `curl` | Windows 10 and later, macOS, Linux |
| `nslookup` | Windows, macOS, Linux |
| `dig` | macOS and Linux (Windows users use `nslookup` or a browser DNS tool) |
| Browser developer tools | Every browser |

## Read in order

| # | Page | What it covers |
|---|---|---|
| 01 | [Recon basics](01-recon-basics.md) | Passive versus active, what you are looking for, the workflow |
| 02 | [WHOIS and email addresses](02-whois.md) | Registrant data, and harvesting addresses |
| 03 | [DNS and subdomains](03-dns-and-subdomains.md) | Record types, subdomain enumeration, certificate transparency, vhosts |
| 04 | [Fingerprinting](04-fingerprinting.md) | Headers, banners, spotting the tech stack and versions |
| 05 | [Crawling](05-crawling.md) | robots.txt, sitemaps, well-known files, source, JavaScript |
| 06 | [Search engine discovery](06-search-engine-discovery.md) | Dorks, and what they turn up |
| 07 | [Web archives](07-web-archives.md) | The Wayback Machine as a source of removed endpoints and old secrets |
| 08 | [Automating recon](08-automating-recon.md) | Chaining the steps, and the order they go in |
| 09 | [Skills assessment](09-skills-assessment.md) | A full recon run on a real target, written up as a report |
| 10 | [OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md) | The list: which Top 10 categories have labs, and where |

## Where you practise

All of these are free, hosted, and need nothing installed.

| Target | What it is, and what it is for |
|---|---|
| [demo.testfire.net](http://demo.testfire.net/) | IBM's deliberately vulnerable banking app. Intended for security testing practice. Use it for crawling, source reading, fingerprinting and finding leaks |
| [scanme.nmap.org](http://scanme.nmap.org/) | Nmap's own scan target. Nmap publishes it specifically so people can practise scanning |
| [public-firing-range.appspot.com](https://public-firing-range.appspot.com/) | Google's Firing Range, built for practising scanners against a real host |
| [PortSwigger Web Security Academy](https://portswigger.net/web-security/all-labs) | Free account, dozens of hosted labs with a solved state and no setup |
| [TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon) | Free. WHOIS, DNS, certificate transparency, Shodan, dorks, with real answers |
| [TryHackMe: Active Reconnaissance](https://tryhackme.com/room/activerecon) | Free. Ping, traceroute, netcat, curl |
| [TryHackMe: DNS in Detail](https://tryhackme.com/room/dnsindetail) | Free. Every DNS record type, with questions |
| [TryHackMe: Search Skills](https://tryhackme.com/room/searchskills) | Free. Search engines and dorking |
| [TryHackMe: ffuf](https://tryhackme.com/room/ffuf) | Free. Content discovery, including a real hidden `/ftp` find |
| [TryHackMe: OhSINT](https://tryhackme.com/room/ohsint) | Free. A full OSINT investigation with flags, as the assessment |

Treat `demo.testfire.net`, `scanme.nmap.org` and the Firing Range as shared public
hosts. Browse them, read them, run the light checks here against them. Do not
hammer them with brute force, and do not run anything destructive. The rooms and
the PortSwigger labs are where you get to be aggressive, because that is what they
are for.

## Ground rules, do not skip this

Recon against a system you do not own and have no written permission to test is
not practice, it is an offence in most places. Everything here is aimed at the
targets above, or at public data that anyone can look up. Running `whois` or
reading `robots.txt` on a public site is normally fine. Running `ffuf` or a zone
transfer against someone else's server is not, unless it is in scope.

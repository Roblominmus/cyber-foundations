# Session 03: web recon

This is our own version of Hack The Box Academy's "Information Gathering - Web
Edition" module. HTB teaches it well, but it costs cubes, so the same ground is
written out here and every technique is paired with a free place to actually
practise it.

The rule for this module: you do not read a page without doing something. Every
page ends with a **Practise** section, and most of them send you to a TryHackMe
room that is free, or to a real target, where you get a real answer you can check.

## Read in order

| # | Page | What it covers |
|---|---|---|
| 01 | [Recon basics](01-recon-basics.md) | Passive versus active, what you are looking for, the workflow, the tooling |
| 02 | [WHOIS](02-whois.md) | Registrant and ownership data, and what it leaks |
| 03 | [DNS and subdomains](03-dns-and-subdomains.md) | Record types, zone transfers, subdomain enumeration, certificate transparency, vhosts |
| 04 | [Fingerprinting](04-fingerprinting.md) | Headers, banners, favicons, spotting the tech stack and versions |
| 05 | [Crawling](05-crawling.md) | robots.txt, sitemaps, well-known files, source comments, JavaScript |
| 06 | [Search engine discovery](06-search-engine-discovery.md) | Dorks, and what they turn up |
| 07 | [Web archives](07-web-archives.md) | The Wayback Machine as a source of removed endpoints and old secrets |
| 08 | [Automating recon](08-automating-recon.md) | Chaining the tools into one pipeline |
| 09 | [Skills assessment](09-skills-assessment.md) | A full recon run, written up as a report |
| 10 | [OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md) | The list: which Top 10 categories have labs, and where |

## Practice targets used here

All of these are free. None of the answers are printed in this repo. Where the
answer belongs to a room, get the flag yourself. Where it belongs to the range
below, the flags are generated fresh on every run.

### The recon range, run it first

[`recon-range/`](recon-range/README.md) is a small target you start on your own
machine with one command. It plants **seven flags**, one per technique, and it is
the only free thing here that lets you practise a zone transfer, vhost discovery
and crawling a genuinely messy site.

```bash
cd recon-range && ./up.sh
```

Pages 03, 04, 05 and 08 are built around it. The rooms below cover the techniques
the range cannot, which is anything that needs the real internet: WHOIS,
certificate transparency, search engines and archives.

| Target | What it is good for |
|---|---|
| **[The recon range](recon-range/README.md)** | DNS records, zone transfer, subdomains, vhosts, fingerprinting, crawling, automation. Seven flags |
| [TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon) | WHOIS, DNS, certificate transparency, Shodan, dorks |
| [TryHackMe: Active Reconnaissance](https://tryhackme.com/room/activerecon) | Ping, traceroute, netcat, curl, banner grabbing |
| [TryHackMe: DNS in Detail](https://tryhackme.com/room/dnsindetail) | Every DNS record type, with questions |
| [TryHackMe: Search Skills](https://tryhackme.com/room/searchskills) | Search engines and dorking properly |
| [TryHackMe: ffuf](https://tryhackme.com/room/ffuf) | Directory and content discovery, including a live /ftp find |
| [TryHackMe: OhSINT](https://tryhackme.com/room/ohsint) | Full OSINT investigation, with flags, as the assessment |
| [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) | A real app to crawl and enumerate on your own machine |
| [PortSwigger Information disclosure](https://portswigger.net/web-security/information-disclosure) | Free labs on finding what a site leaks |

## Tools you will need

```bash
sudo apt install whois dnsutils curl whatweb nmap gobuster ffuf
# optional, better subdomain and probing tools
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
```

## Ground rules, do not skip this

Recon against a system you do not own and have no written permission to test is
not practice, it is an offence in most places. Everything here is aimed at the
rooms above, at a target you own, or at public data that anyone can look up.
Running `whois` or reading `robots.txt` on a public site is normally fine. Running
`ffuf` or a zone transfer against someone else's server is not, unless it is in
scope.

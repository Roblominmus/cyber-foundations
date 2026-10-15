# Session 03: web recon

Our own version of Hack The Box Academy's "Information Gathering - Web Edition".
HTB teaches it well but it costs cubes, so the same ground is written out here and
every technique is paired with a free place to actually practise it.

## It works on any operating system

This module is written for Linux, macOS **and** Windows.

- The practice range needs **Docker and nothing else**. No bash, no Python, no
  Kali, no chmod. Start it with one command that is identical on all three systems.
- Where a command differs, both versions are given. Windows has no `dig`, so the
  range ships a `tools` container that runs the same `dig` everywhere, and the
  native `nslookup` path is written out too.
- Certificate transparency, WHOIS, search engines and archives are **browser
  tasks**. They need no local tooling at all, so they work for everyone and they
  work for anyone who cannot run Docker.

## Reading this on GitHub

If you are reading on github.com, two kinds of task work straight away:

- Everything on pages 02, 03, 06 and 07 that is a browser task. The links are
  there, the questions are there, you can do them with no setup.
- Everything on pages 03, 04, 05, 08 and 09 that uses the range. For those you need
  the range on your machine. The [range README](recon-range/README.md) gives you
  the clone and the Download ZIP instructions, both.

## Read in order

| # | Page | What it covers |
|---|---|---|
| 01 | [Recon basics](01-recon-basics.md) | Passive versus active, what you are looking for, the workflow, the tooling |
| 02 | [WHOIS and email addresses](02-whois.md) | Registrant data, and harvesting addresses |
| 03 | [DNS and subdomains](03-dns-and-subdomains.md) | Record types, zone transfers, subdomain enumeration, certificate transparency, vhosts |
| 04 | [Fingerprinting](04-fingerprinting.md) | Headers, banners, favicons, spotting the tech stack and versions |
| 05 | [Crawling](05-crawling.md) | robots.txt, sitemaps, well-known files, source, JavaScript, documents, exposed Git |
| 06 | [Search engine discovery](06-search-engine-discovery.md) | Dorks, and what they turn up |
| 07 | [Web archives](07-web-archives.md) | The Wayback Machine as a source of removed endpoints and old secrets |
| 08 | [Automating recon](08-automating-recon.md) | Chaining the tools into one pipeline |
| 09 | [Skills assessment](09-skills-assessment.md) | A full recon run, written up as a report |
| 10 | [OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md) | The list: which Top 10 categories have labs, and where |

## What you practise where

| Technique | Where |
|---|---|
| DNS records, subdomains, zone transfer, vhosts | **The range**, flags 1, 2 and 7 |
| Fingerprinting headers and versions | **The range**, and any site you are allowed to look at |
| Crawling: robots.txt, sitemaps, well-known paths | **The range**, flags 3, 4 and 5 |
| Source, JavaScript, exposed Git, document metadata | **The range**, flags 3, 6 and 8 |
| Email address harvesting | **The range**, and the WHOIS room |
| WHOIS and certificate transparency | [TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon), browser tasks |
| Search engines and dorks | [TryHackMe: Search Skills](https://tryhackme.com/room/searchskills), browser tasks |
| Web archives | Browser and a small API call, no tools needed |
| Full OSINT investigation | [TryHackMe: OhSINT](https://tryhackme.com/room/ohsint) |
| A real app to crawl | [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) |
| Leaking information on purpose | [PortSwigger: Information disclosure](https://portswigger.net/web-security/information-disclosure) |

## The range

[`recon-range/`](recon-range/README.md) is a DNS server and a messy web server on
your own machine, with eight flags planted in it. It runs on Docker alone:

```bash
cd recon-range
docker compose up -d
```

Its README has the full command list, the Windows paths, and the flag table.

## Ground rules, do not skip this

Recon against a system you do not own and have no written permission to test is
not practice, it is an offence in most places. Everything here is aimed at the
range, at the rooms above, or at public data that anyone can look up. Running
`whois` or reading `robots.txt` on a public site is normally fine. Running `ffuf`
or a zone transfer against someone else's server is not, unless it is in scope.

# 01: Recon basics

[Session index](README.md) | [Next: WHOIS and email addresses](02-whois.md)

Before any exploit, there is recon. Recon is the work of finding out what exists,
what it runs, and what it exposes, without touching anything in a way that would
annoy the owner. Everything later depends on it, because you cannot attack what
you have not found.

## Passive and active

| | Passive | Active |
|---|---|---|
| What you do | Read public sources | Talk to the target |
| Examples | WHOIS, DNS lookups, certificate transparency, search engines, archives | Port scans, directory brute force, banner grabbing, vhost fuzzing |
| Can the target see you | No | Usually yes, in logs |
| Risk | Almost none | Can be noisy or disruptive |

Start passive, because it is free, invisible, and often enough on its own. Move to
active once you understand the shape of the target.

## What you are actually looking for

Recon is not collecting everything. It is collecting the things that lead
somewhere. In practice that means:

- **Names**: domains, subdomains, virtual hosts, usernames, email addresses.
- **Infrastructure**: IPs, hosting provider, CDN, mail servers, name servers.
- **Technology**: web server, language, framework, CMS, and their versions.
- **Entry points**: login pages, APIs, upload forms, admin panels, old endpoints.
- **Leaks**: exposed files, backup archives, source code, keys, credentials,
  verbose errors, directory listings.

That last category is where recon usually pays for itself. Most easy wins are
things somebody forgot to hide.

## The workflow

1. **Scope.** Write down what you are allowed to touch. Everything below is
   inside that line only.
2. **Passive first.** WHOIS, DNS, certificate transparency, search engines,
   archives. Build a list of names and infrastructure.
3. **Fingerprint.** Grab headers and banners. Work out what it runs.
4. **Crawl and discover.** robots.txt, sitemaps, well-known paths, then content
   discovery with a wordlist.
5. **Automate.** Once you know the steps, chain them so you can repeat them on
   the next target.
6. **Record as you go.** Findings you did not write down are findings you have
   lost. Every name, version and path goes in your notes with the command that
   produced it.

## Keep a notes file from the first minute

Do not try to hold this in your head. One file per target, and for every finding
record the command and the output. A plain layout:

```
TARGET: <domain>
SCOPE: <what is in scope>
--- names
- sub.example.com    from crt.sh
- vpn.example.com    from DNSDumpster
--- infra
- 203.0.113.10       A record for www
- cloudflare         CDN, so real IP is hidden
--- tech
- nginx 1.18.0       Server header
- PHP/7.4            X-Powered-By
--- entry points
- /admin/login       found in robots.txt Disallow
- /api/v1/           found in JS bundle
--- leaks
- /.git/HEAD         returns 200
```

## The tooling, and what each is for

| Tool | Job |
|---|---|
| `whois` | Domain ownership and registration data |
| `dig`, `nslookup`, `host` | DNS records |
| `subfinder`, `amass`, `dnsrecon` | Subdomain enumeration |
| `whatweb`, `curl -I` | Fingerprinting |
| `nmap` | Ports and service versions |
| `ffuf`, `gobuster` | Content, directory and vhost discovery |
| `httpx` | Probe a list of hosts fast, and collect their headers and status |
| `theHarvester` | Emails, names and hosts from public sources |
| Browser and Wayback Machine | Manual reading, and the past |

You do not need all of them. You need to know what job each one does, so you can
reach for the right one.

## Practise

Nothing to install on this page or any page in this module. Everything is a
browser, plus the free rooms. It works on Windows, macOS and Linux, and it works
if you are reading this on GitHub.

### Your practice target

Open [demo.testfire.net](http://demo.testfire.net/) in a browser. It is IBM's
deliberately vulnerable banking application, published so people can practise on
it. From here on, this is your target unless a task says otherwise.

Two more worth knowing:

- [scanme.nmap.org](http://scanme.nmap.org/), Nmap's own scan target, published
  for exactly this purpose
- [public-firing-range.appspot.com](https://public-firing-range.appspot.com/),
  Google's Firing Range, built for practising scanners

These are shared public hosts. Browse them, read them, run the light checks in
this module. Do not brute force them. The rooms are where you get to be
aggressive.

### The two passive rooms

Both free, both need only a browser and a free account:

1. **[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)**.
   WHOIS, DNS, certificate transparency, Shodan and search engines. This covers
   pages 02, 03, 06 and 07. Answer every question in it.
2. **[TryHackMe: Active Reconnaissance](https://tryhackme.com/room/activerecon)**.
   Ping, traceroute, netcat and curl. The active half, and it feeds page 04.

### Keep a notes file from the first minute

One file per target. For every finding, the command or the click that produced it,
and the output. This is the real deliverable of the module.

```
TARGET: demo.testfire.net
--- names and infra
- 65.x.x.x        resolves for demo.testfire.net
--- tech
- Server header   from devtools, Network tab
--- entry points
- /login.jsp      linked from the home page
--- leaks
- robots.txt      disallows nothing useful, recorded anyway
--- findings
- no HTTPS on the login form, meaning credentials cross in clear text
```

The last block is the point. A finding with no evidence is not a finding.

[Session index](README.md) | [Next: WHOIS and email addresses](02-whois.md)

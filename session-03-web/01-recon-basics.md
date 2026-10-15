# 01: Recon basics

[Session index](README.md) | [Next: WHOIS](02-whois.md)

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

First, start the practice target, because you will use it from page 03 onwards:

```bash
cd recon-range && ./up.sh
```

That is a small DNS and web server on your own machine with seven flags planted in
it. Leave it running.

Then do the passive half, properly, before you touch anything active on a real
domain. Two rooms, both free, both with real answers you have to find:

1. **[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)**.
   Work through it and answer every question. This covers WHOIS, DNS lookups,
   certificate transparency, Shodan and search engines, which are pages 02, 03, 06
   and 07 of this module. Keep your answers, you will reuse the skills.

2. **[TryHackMe: Active Reconnaissance](https://tryhackme.com/room/activerecon)**.
   Ping, traceroute, netcat and curl. This is the active half, and it feeds page
   04.

While you do them, keep the notes file described above, for the target each room
gives you. That habit is the actual deliverable of this module.

[Session index](README.md) | [Next: WHOIS](02-whois.md)

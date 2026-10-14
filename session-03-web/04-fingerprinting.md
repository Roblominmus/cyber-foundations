# 04: Fingerprinting

[Previous: DNS and subdomains](03-dns-and-subdomains.md) | [Session index](README.md) | [Next: Crawling](05-crawling.md)

## What it is

Fingerprinting is working out what a target runs: web server, language,
framework, CMS, and ideally the version of each. Versions matter because a
version plus a search is often an exploit.

You do this without logging in, mostly by reading what the server volunteers.

## HTTP response headers

This is the fastest win and it takes one command.

```bash
curl -I https://example.com
```

Headers that leak:

| Header | Tells you |
|---|---|
| `Server` | Web server and often its version, for example `nginx/1.18.0` |
| `X-Powered-By` | Language or framework, for example `PHP/7.4.3`, `Express` |
| `X-AspNet-Version` | .NET version |
| `X-Generator` | CMS, common on Drupal and WordPress |
| `X-Drupal-Cache`, `X-Drupal-Dynamic-Cache` | Drupal, confirmed |
| `Set-Cookie` | Framework fingerprints. `PHPSESSID` is PHP, `JSESSIONID` is Java, `ASP.NET_SessionId` is .NET, `csrftoken` suggests Django |
| `Via`, `X-Cache`, `CF-Ray`, `X-Amz-Cf-Id` | CDN or proxy in front, so you may be seeing the CDN not the origin |

If `Server` says Cloudflare, you are looking at a proxy. The origin is behind it
and the headers are the CDN's, not the application's.

## Banner grabbing without HTTP

Not everything speaks HTTP.

```bash
# look at what a service says when you connect
nc -nv 203.0.113.10 22
nc -nv 203.0.113.10 21

# send a minimal request by hand
printf 'HEAD / HTTP/1.0\r\n\r\n' | nc 203.0.113.10 80
```

SSH, FTP and SMTP all announce themselves on connect. That banner plus a version
search is a classic path to a first foothold.

## Automated fingerprinting

```bash
# one site
whatweb https://example.com

# a list, quietly, with aggression level 1 (passive)
whatweb -i subs.txt --aggression 1 -q

# nmap service and version detection
nmap -sV -p 80,443,8080,8443 203.0.113.10
```

Browser extensions such as Wappalyzer do the same thing visually and are handy
when you are clicking around by hand.

## Two more things people forget

**The favicon.** The little icon has a hash. The same application on two servers
usually has the same favicon hash, so it can identify a product, and by
extension its version. This is a real technique that catches things headers miss.

**Default and error pages.** A default Apache or IIS page names the product. A
verbose error page can name the framework, the file path, and the database. Both
are free fingerprinting, and both are also findings in their own right, because
a verbose error is an information disclosure bug.

## From version to exploit

Once you have a version, in this order:

1. Search the product and version for known vulnerabilities.
2. Check the vendor's own security advisories.
3. Only then look for a public exploit, and read it before you run it.

Sending an exploit to a version that does not match is how people crash services.
Confirm the version first.

## Practise

**Room task.** [TryHackMe: Active Reconnaissance](https://tryhackme.com/room/activerecon)
(free). The room has you use `curl`, browser developer tools and netcat against a
target, and asks you to note what the responses tell you. Pay attention to the
questions about headers, they are exactly this page.

**Real world task.** Pick three sites you are allowed to look at, ideally ones you
expect to differ: a large company, a small business, and a hobby or personal site.

For each, record:

1. The full `Server` header.
2. Any `X-Powered-By` or similar.
3. The session cookie names, and what language or framework they suggest.
4. What `whatweb --aggression 1` reports.
5. Whether a CDN is in front, and how you can tell.
6. The exact version numbers you can find, and whether they are current.

**Questions to answer in your notes:**

- Which of the three gave away the most, and why might that be?
- Why is a CDN header bad news for fingerprinting, and what would you do instead?
- You see `PHPSESSID`. What do you now know, and what do you still not know?

[Previous: DNS and subdomains](03-dns-and-subdomains.md) | [Session index](README.md) | [Next: Crawling](05-crawling.md)

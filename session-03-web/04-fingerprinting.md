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

### Task 1: read the headers in the browser, no tools

1. Open [demo.testfire.net](http://demo.testfire.net/).
2. Open developer tools, then the Network tab, then reload the page.
3. Click the first request for the page itself, not an image.
4. Read the response headers.

Record:

| Header | Your target's value | What it tells you |
|---|---|---|
| `Server` | | Web server and version |
| `X-Powered-By` | | Language or framework |
| `Set-Cookie` names | | Session technology |
| `Via`, `X-Cache`, `CF-Ray` | | Anything in front of the origin |

1. What web server and version is it?
2. What do the cookie names suggest about the language?
3. Is anything in front of the origin?

**Optional, if you have a terminal.** `curl` ships with Windows 10 and later,
macOS and Linux, so this needs no install:

```bash
curl -I http://demo.testfire.net/
```

On Windows use `curl.exe` if plain `curl` opens something else.

### Task 2: version detection against a host meant for it

[scanme.nmap.org](http://scanme.nmap.org/) is Nmap's own target, published so
people can practise scanning it. If you have `nmap`, this is authorised and
expected:

```bash
nmap -sV scanme.nmap.org
```

If you do not have nmap, skip it. The browser tasks below cover the same idea.

### Task 3: compare three sites

Three sites you are allowed to look at: a large company, a small business, and a
personal site. Do step 1 for each and fill this in.

| | Large company | Small business | Personal site |
|---|---|---|---|
| `Server` | | | |
| `X-Powered-By` or similar | | | |
| Session cookie, and what it implies | | | |
| CDN in front, and how you know | | | |
| Versions you can pin down | | | |

### Room task

**[TryHackMe: Active Reconnaissance](https://tryhackme.com/room/activerecon)**
(free). The header and curl questions there are exactly this page, on a real host,
with real answers.

**Questions for your notes:**

- Which site gave away the most, and why?
- A CDN header hides the origin. What do you do instead?
- You see `PHPSESSID`. What do you know, and what do you still not know?
- Why is a version number more useful than a product name?

[Previous: DNS and subdomains](03-dns-and-subdomains.md) | [Session index](README.md) | [Next: Crawling](05-crawling.md)

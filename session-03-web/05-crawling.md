# 05: Crawling

[Previous: Fingerprinting](04-fingerprinting.md) | [Session index](README.md) | [Next: Search engine discovery](06-search-engine-discovery.md)

## Two different jobs

People mix these up, so separate them:

- **Crawling** is following the links a site already gives you. You are reading
  what is there. Fast, quiet, no guessing.
- **Content discovery** is guessing paths that are not linked. That is `ffuf` with
  a wordlist, and it is page 08 territory.

Do the crawl first. It is free, it finds things discovery would miss, and it often
gives you a wordlist worth using.

## robots.txt

The first file to read on any site. It is a list of instructions to crawlers,
which means it is often a list of the paths the owner does not want indexed. That
is close to a list of the interesting paths.

```bash
curl -s https://example.com/robots.txt
```

Look for:

- `Disallow:` entries. These are the good ones. `/admin`, `/backup`, `/api`,
  `/staging`.
- `Allow:` entries that contradict a broad disallow, which usually marks
  something deliberate.
- Non standard entries such as `Sitemap:` pointing at a location you did not know.
- Comments, which sometimes name an internal tool or a person.

A `Disallow` is a request, not a control. Nothing stops you fetching the path, and
usually it is worth a look.

## sitemap.xml

The opposite of robots.txt. It lists what the site wants found.

```bash
curl -s https://example.com/sitemap.xml
```

Useful for enumerating every page and, on some CMSes, every post and author.

## Well-known files

A short list worth trying on every target. None of these should be public, and
several often are.

| Path | What it is, and why you care |
|---|---|
| `/.well-known/security.txt` | Contact for reporting bugs, sometimes names an internal team |
| `/.git/HEAD` | If this returns 200, the whole repository is often downloadable |
| `/.env` | Application secrets: database passwords, API keys |
| `/.DS_Store` | macOS folder listing, leaks file and folder names |
| `/backup.zip`, `/site.tar.gz`, `/db.sql` | Exactly what it says |
| `/phpinfo.php` | Full server configuration, modules and paths |
| `/server-status` | Apache status page, leaks every request |
| `/swagger.json`, `/openapi.json` | API documentation, hands you the whole API |
| `/actuator`, `/actuator/env` | Spring Boot, often leaks config and secrets |

Do a quick pass by hand with these, then let a wordlist catch the rest.

## Reading the HTML source

The source is full of things the rendered page hides.

- **HTML comments.** Developers leave notes. `<!-- TODO: remove before launch -->`
  is a real thing that ships. So are commented out debug panels and old paths.
- **Hidden form fields.** `<input type="hidden" name="price" value="10">` tells you
  the price is client controlled, which is a business logic bug waiting to happen.
- **Link and script tags.** Every path in them is a path to fetch, and every JS
  file is a file to read.
- **Meta tags.** Generator strings name the CMS and version.

## JavaScript files are the real prize

Modern apps put their whole API in the JavaScript. Read it.

```bash
# list the scripts
curl -s https://example.com | grep -oE 'src="[^"]+\.js[^"]*"' | sort -u

# pull the ones you found and look for paths and secrets
curl -s https://example.com/static/app.js | grep -oE '"/[a-zA-Z0-9_/-]+"' | sort -u

# look for things that should never be in a bundle
curl -s https://example.com/static/app.js | grep -iE 'api_key|apikey|secret|token|password|bearer|aws_'
```

A JavaScript bundle is a map of the API, and sometimes it contains a key that was
never meant to leave the developer's machine. Both are findings.

## Crawling with tools

```bash
# follow links and collect URLs and JS
katana -u https://example.com -d 3 -jc -silent -o urls.txt

# a simpler classic
gospider -s https://example.com -d 2 -o out/

# just look at the robots and sitemap and follow on from there yourself
curl -s https://example.com/sitemap.xml | grep -oE '<loc>[^<]+' | cut -d'>' -f2
```

Whichever you use, feed everything you find back in. Crawling is iterative: new
URLs lead to new URLs.

## Practise

### On the range: robots.txt, flags 3, 4 and 5

With the range up, read what it does not want crawled:

```bash
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/robots.txt
```

1. Every `Disallow` is a path somebody did not want indexed. Fetch each one
   directly, because a request is not a control:

```bash
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/ftp/
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/internal/
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/backup/
```

2. The directory listing you get is already a finding. Inside one of these
   directories is a file of staff passwords. **Flag 4** is in it. Name the other
   file you found there as well and say what it leaks.
3. **Flag 5** is on a page inside another disallowed directory.
4. Work out which of the three disallowed paths gave you something and which gave
   you nothing, and write that down. A path that returns 404 is still worth
   recording as "checked".

### On the range: source and JavaScript, flags 3 and 6

Crawling is not only paths. Read what the pages hand you.

```bash
# the site links to two pages, fetch both and read the raw source
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/ | grep -oE 'href="[^"]+"|src="[^"]+"'
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/about.html | grep -i '<!--'
```

5. **Flag 3** is in an HTML comment on one of those pages. Developers leave notes,
   and notes ship.
6. Now the JavaScript:

```bash
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/static/app.js
```

7. List every API endpoint the bundle names. How many of them does the user
   interface actually link to?
8. **Flag 6** is a key in that file. On a real target, a key in a client side
   bundle is a finding on its own, because anyone can read it.

### On the range: the well-known pass

Do not forget the fixed paths. Run all of these and record which return anything
other than 404:

```bash
for p in /.well-known/security.txt /.git/HEAD /.env /.DS_Store /backup.zip \
         /phpinfo.php /server-status /swagger.json /openapi.json /actuator; do
  code=$(curl -s -o /dev/null -w '%{http_code}' -H "Host: www.recon.lab" "http://127.0.0.1:8080$p")
  printf '%-28s %s\n' "$p" "$code"
done
```

Two of them return something. One is a legitimate contact file. The other is a
serious finding on a real target: explain what an attacker does with it.

### Room and lab tasks

- **[TryHackMe: ffuf](https://tryhackme.com/room/ffuf)** (free). Content discovery
  against a live target, including finding a hidden `/ftp` folder. Same idea as
  step 1 to 3 above, with the room's own answers.
- Run [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) locally and do
  the same pass against it: `robots.txt`, the `/ftp` folder, the JavaScript
  bundles, and the API paths in them.
- The two labs on
  **[PortSwigger: Information disclosure](https://portswigger.net/web-security/information-disclosure)**
  about leaking information through error messages and through `robots.txt` and
  backup files.

**Questions to answer in your notes:**

- Why is `robots.txt` useful to an attacker, given it is only a request?
- You found `/.git/HEAD` returns 200. What is the next step, and what could go
  wrong if you skip it?
- What is the difference between crawling and content discovery, and why do the
  crawl first?

[Previous: Fingerprinting](04-fingerprinting.md) | [Session index](README.md) | [Next: Search engine discovery](06-search-engine-discovery.md)

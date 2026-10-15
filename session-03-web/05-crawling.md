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

Reading robots.txt and page source is passive, legal on any site, and needs
nothing installed. Guessing paths is not, so that part lives in the room.

### Task 1: robots.txt and the sitemap

On a site you are allowed to read, open:

```
https://<the site>/robots.txt
https://<the site>/sitemap.xml
```

1. List every `Disallow` path. Each one is a path somebody did not want indexed.
2. Fetch each disallowed path in the browser. A request is not a control.
3. Was anything there that is not linked from the site?
4. Note the result for each path, including the ones that give nothing. "Checked,
   404" belongs in your notes.

Some sites have no robots.txt at all. That is a result too, and it is worth
recording as one.

### Task 2: read the source

View the source of the home page and two others.

1. Search for `<!--`. List every comment and what it reveals.
2. Search for `type="hidden"`. Is anything important client controlled?
3. List every `<script src="...">`. Open each one and search for `api`, `key`,
   `token`, `secret`, and paths starting with `/`.
4. Note the `<meta name="generator">` if there is one.

A comment that says "remove before launch" is a real thing that ships.

### Task 3: the well-known pass

Try these on any site. Record the status of each:

```
/.well-known/security.txt
/.git/HEAD
/.env
/.DS_Store
/backup.zip
/phpinfo.php
/server-status
/swagger.json
/openapi.json
/actuator
```

Most will be 404 and that is the normal result. If any returns 200, you have a
real finding.

1. Which return anything other than 404?
2. Which two would matter most on a real target, and what would you do next?
3. `/.well-known/security.txt` is legitimate. What does it give you?

### Task 4: the room, where the answers are

Content discovery needs a target you are authorised to hammer, so this is the
room:

**[TryHackMe: ffuf](https://tryhackme.com/room/ffuf)** (free). It runs against a
live target, includes finding a hidden `/ftp` folder and a file inside it, and has
real answers. This is the guided, graded version of everything above.

### Task 5: the labs

**[PortSwigger: Information disclosure](https://portswigger.net/web-security/information-disclosure)**
(free account). One lab is about leaking information through error messages, the
other about `robots.txt` and backup files. Both are hosted, need no setup, and
tell you when you have solved them.

**Questions for your notes:**

- Why is `robots.txt` useful to an attacker when it is only a request?
- You find `/.git/HEAD` returns 200. What is the next step, and the risk of
  skipping it?
- Why do the crawl before the content discovery?
- Why is a 404 worth writing down?

[Previous: Fingerprinting](04-fingerprinting.md) | [Session index](README.md) | [Next: Search engine discovery](06-search-engine-discovery.md)

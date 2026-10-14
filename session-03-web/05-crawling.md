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

**Room task 1.** [TryHackMe: ffuf](https://tryhackme.com/room/ffuf) (free). This
room uses `ffuf` for content discovery against a live target, and one of the tasks
is finding a hidden `/ftp` folder and its contents. That is this page plus page 08,
and the room has real answers to find.

**Room task 2.** Run [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/)
locally, then:

1. Read `robots.txt` and note every disallowed path. One of them is the `/ftp`
   folder with a file listing in it.
2. Fetch the main page and list every JavaScript file.
3. Grep one of the bundles for `/rest/` and similar path patterns. Juice Shop
   puts its API on display this way, and you will find endpoints the UI never
   offers you.
4. Look for an exposed backup or log file in `/ftp`.

**Lab task.** [PortSwigger: Information disclosure](https://portswigger.net/web-security/information-disclosure)
(free labs). Do the labs on leaking information through error messages and on
`robots.txt` and backup files. They are short and they are exactly the "leaks"
category from page 01.

**Questions to answer in your notes:**

- Why is `robots.txt` useful to an attacker, given it is only a request?
- What is the difference between crawling and content discovery, and why do the
  crawl first?
- You find `/.git/HEAD` returns 200. What is your next step, and what could go
  wrong if you skip it?

[Previous: Fingerprinting](04-fingerprinting.md) | [Session index](README.md) | [Next: Search engine discovery](06-search-engine-discovery.md)

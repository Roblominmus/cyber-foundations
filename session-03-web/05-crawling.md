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

Everything here is a browser, and optionally `curl`, which ships with Windows 10
and later, macOS and Linux. Nothing to install.

### Task 1: robots.txt and the sitemap

Open these in the browser on your target:

```
http://demo.testfire.net/robots.txt
http://demo.testfire.net/sitemap.xml
```

1. List every `Disallow` path. Each one is a path somebody did not want indexed.
2. Fetch each disallowed path directly in the browser. A request is not a control.
3. Was anything there that is not linked from the site?
4. Note the result for each path, including the ones that give nothing. "Checked,
   404" belongs in your notes.

### Task 2: read the source

View the source of the home page and of two others. The rendered page hides things
the source does not.

1. Search the source for `<!--`. List every comment and what it reveals.
2. Search for `type="hidden"`. Is anything important client controlled?
3. List every `<script src="...">`. Open each one and search for `api`, `key`,
   `token`, `secret`, and any path starting with `/`.
4. Note the `<meta name="generator">` if there is one.

An HTML comment that says "TODO remove before launch" is a real thing that ships.

### Task 3: the well-known pass

Try these in the browser. Record the status of each:

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

1. Which return anything other than 404?
2. Which two would matter most on a real target, and what would you do next?
3. `/.well-known/security.txt` is legitimate. What does it give you?

If you have `curl`, the same thing faster. On Windows, `curl.exe`:

```bash
for p in /.well-known/security.txt /.git/HEAD /.env /.ds_store /backup.zip \
         /phpinfo.php /server-status /swagger.json /openapi.json /actuator; do
  printf "%-28s " "$p"
  curl -s -o /dev/null -w "%{http_code}\n" "http://demo.testfire.net$p"
done
```

### Task 4: document metadata

Find any document your target publishes, a PDF or an office file, and download it.
Then look at its metadata.

**In a browser:** open the PDF, then look at File, then Properties. Author, creator
and producer are almost always there.

**If you have a terminal**, and you are on Linux or macOS, `strings` needs no
install:

```bash
strings report.pdf | grep -iE "author|creator|producer|title"
```

On Windows, open the file in Notepad and search for the same words, or use
PowerShell:

```powershell
Get-Content .\report.pdf -Raw | Select-String -Pattern "Author|Creator|Producer" -AllMatches
```

1. Who authored it, and what software made it?
2. Why is the software name a fingerprinting finding?
3. Why does an author name matter when you already have the email addresses?

### Task 5: the rooms and the labs

- **[TryHackMe: ffuf](https://tryhackme.com/room/ffuf)** (free). Content discovery
  against a live target, including finding a hidden `/ftp` folder and a file
  inside it. This is the guided version of everything above, with real answers.
- The two labs on
  **[PortSwigger: Information disclosure](https://portswigger.net/web-security/information-disclosure)**
  (free account). One is about leaking information through error messages, the
  other about `robots.txt` and backup files. Both are hosted, no setup.

**Questions for your notes:**

- Why is `robots.txt` useful to an attacker when it is only a request?
- You find `/.git/HEAD` returns 200. What is the next step, and the risk of
  skipping it?
- Why is an author name in a PDF a finding?
- Why do the crawl before the content discovery?

[Previous: Fingerprinting](04-fingerprinting.md) | [Session index](README.md) | [Next: Search engine discovery](06-search-engine-discovery.md)

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

Everything here is `curl`, which ships with Windows 10 and later, macOS and Linux.
On Windows use `curl.exe` if plain `curl` misbehaves.

### Task 1: robots.txt, flags 4 and 5

```bash
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/robots.txt
```

1. List every `Disallow` path. Each one is a path somebody did not want indexed.
2. Fetch each one directly, because a request is not a control:

```bash
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/ftp/
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/internal/
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/backup/
```

3. Two of them return something. **Flag 4** is inside a file of staff passwords
   in one directory. **Flag 5** is on a page in the other.
4. Name the second file in the `/ftp` listing and say what it leaks.
5. One disallowed path returns nothing. Record it as checked and explain why "I
   looked and there was nothing" still belongs in your notes.

### Task 2: source and JavaScript, flags 3 and 6

```bash
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/about.html
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/static/app.js
```

6. **Flag 3** is in an HTML comment. Developers leave notes, and notes ship.
7. List every API endpoint the JavaScript names. How many does the user interface
   actually link to?
8. **Flag 6** is a key in that bundle. Explain why a key in client side code is a
   finding even when it works perfectly.

### Task 3: an exposed Git directory, flag 8

```bash
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/.git/HEAD
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/.git/config
```

9. **Flag 8** is in the `origin` URL in the config, as the password in a
   `https://user:pass@host` style remote.
10. On a real target, a readable `.git` directory usually means the whole
    repository, including its history, can be reconstructed. Explain what you
    would do next and why you would not just download it without thinking.

### Task 4: the well-known pass, and document metadata

Not everything hides in the site's own links.

**Linux or macOS:**

```bash
for p in /.well-known/security.txt /.git/HEAD /.env /.DS_Store /backup.zip \
         /phpinfo.php /server-status /swagger.json /openapi.json /actuator; do
  code=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: www.recon.lab" "http://127.0.0.1:8080$p")
  printf "%-28s %s\n" "$p" "$code"
done
```

**Windows PowerShell:**

```powershell
$paths = "/.well-known/security.txt","/.git/HEAD","/.env","/.DS_Store","/backup.zip",
         "/phpinfo.php","/server-status","/swagger.json","/openapi.json","/actuator"
foreach ($p in $paths) {
  $c = curl.exe -s -o NUL -w "%{http_code}" -H "Host: www.recon.lab" "http://127.0.0.1:8080$p"
  "{0,-30} {1}" -f $p, $c
}
```

11. Which paths return something other than 404? Which two matter most, and why?
12. Now the document. The site links a PDF:

```bash
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/public/annual-report.pdf -o report.pdf
```

Read its metadata. Any of these works:

```bash
exiftool report.pdf                 # if you have it
strings report.pdf | head -20       # no tools needed at all
```

On Windows, `strings` is not built in, but Notepad or any text editor will show
these lines, and PowerShell can too:

```powershell
Get-Content .\report.pdf -Raw | Select-String -Pattern "Author|Creator|Title" -AllMatches
```

13. Who is the author, and what software made the document?
14. Cross reference the author with the staff list in `/ftp`. Why does that
    matter more than either finding alone?

### Room and lab tasks

- **[TryHackMe: ffuf](https://tryhackme.com/room/ffuf)** (free): content discovery
  against a live target, including a hidden `/ftp` folder.
- [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) locally: the same
  pass, for real. robots.txt, `/ftp`, the JavaScript bundles, the API paths.
- The two labs on
  **[PortSwigger: Information disclosure](https://portswigger.net/web-security/information-disclosure)**
  about error messages, and about `robots.txt` and backup files.

**Questions for your notes:**

- Why is `robots.txt` useful to an attacker when it is only a request?
- You find `/.git/HEAD` returns 200. What is the next step, and the risk of
  skipping it?
- Why is an author name in a PDF a finding?
- Why do the crawl before the content discovery?

[Previous: Fingerprinting](04-fingerprinting.md) | [Session index](README.md) | [Next: Search engine discovery](06-search-engine-discovery.md)

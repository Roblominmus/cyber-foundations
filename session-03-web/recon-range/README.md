# The recon range

A target you run on your own machine. It exists because the rooms cover the passive
techniques well, but almost nothing free lets you practise DNS zone transfers,
vhost discovery, crawling a messy site, document metadata, exposed Git
directories, or chaining the tools into a pipeline.

It plants **eight flags**, generated fresh on every run, so the answers are never
in this repo.

## What this covers, and what it does not

| Information gathering technique | Where to practise |
|---|---|
| DNS records, every type | The range, flag 1 |
| Zone transfer, AXFR | The range, flag 2 |
| Subdomain enumeration | The range, flag 1 and 2, page 03 |
| Virtual host discovery | The range, flag 7 |
| Fingerprinting, headers, versions | The range |
| Crawling, robots.txt, sitemaps | The range, flags 3, 4, 5 |
| Reading source and JavaScript | The range, flags 3, 6 |
| Exposed Git directory | The range, flag 8 |
| Document metadata | The range, no flag, it is a finding |
| Email address harvesting | The range, no flag, it is a finding |
| **Certificate transparency logs** | Needs the real internet, page 03 |
| **WHOIS** | Needs the real internet, page 02 |
| **Search engines and dorks** | Needs the real internet, page 06 |
| **Web archives** | Needs the real internet, page 07 |

The bottom four cannot be faked locally, because they are services that index the
real internet. Those are browser tasks, so they work for you no matter what
operating system you are on.

## Requirements

**Docker, and nothing else.** No bash, no Python, no chmod, no Kali. Every command
below works the same on Linux, macOS and Windows.

If you cannot run Docker, skip the range and do the room and browser tasks on each
page instead. The module still works, it is just less hands on.

## Getting these files, if you are reading on GitHub

You need the folder on your machine to run it. Either:

**Clone the repo:**

```bash
git clone https://github.com/Roblominmus/cyber-foundations
cd cyber-foundations/session-03-web/recon-range
```

**Or download it without git:** on the repo page, use the green **Code** button,
then **Download ZIP**, and unzip it. Windows can unzip it natively.

## Start it

From inside the `recon-range` folder:

```bash
docker compose up -d
```

First run pulls three small images. When it says done:

| Service | Address | Notes |
|---|---|---|
| DNS | `127.0.0.1:15353` | Zone `recon.lab`. Port 5353 is often taken, so it is 15353 |
| Web | `127.0.0.1:8080` | Needs a `Host` header, that is the point |

Stop it:

```bash
docker compose down
```

Get **fresh flags** (do this before the timed assessment, so you have not seen the
answers):

```bash
docker compose down && docker compose up -d
```

## Talking to it

### DNS

**On Linux or macOS**, if you have `dig`:

```bash
dig @127.0.0.1 -p 15353 recon.lab ANY
dig @127.0.0.1 -p 15353 AXFR recon.lab
```

**On Windows**, there is no `dig`. Two options, both fine.

Native, using `nslookup` which is already installed:

```powershell
nslookup -port=15353 recon.lab 127.0.0.1
```

`nslookup` cannot do a zone transfer easily. For that, use the tools container,
which works on every operating system because it runs the same Linux image:

```bash
docker compose run --rm tools @dns recon.lab ANY
docker compose run --rm tools @dns AXFR recon.lab
docker compose run --rm tools @dns portal.recon.lab A
```

That is the same `dig` everywhere, so if you are on Windows and want the full
experience, use the tools container for all the DNS work.

### Web

`curl` ships with Windows 10 and later, macOS and Linux, so this is the same
command for everybody. Windows: if typing `curl` opens something else, use
`curl.exe` instead.

```bash
curl -H "Host: www.recon.lab" http://127.0.0.1:8080/
```

The `Host` header is not optional. The server has several virtual hosts on one IP
and decides which to serve from that header alone. Without it you get a 404.

In PowerShell, quote it the same way. If your shell mangles the header, use:

```powershell
curl.exe -H "Host: www.recon.lab" http://127.0.0.1:8080/
```

## The eight flags

Find them in this order. The page column is which page of this module teaches the
technique.

| Flag | Where it hides | Technique | Page |
|---|---|---|---|
| 1 | A TXT record on the zone | DNS records | 03 |
| 2 | A name only visible in a full zone dump | Zone transfer | 03 |
| 3 | An HTML comment on a page | Reading source | 05 |
| 4 | A file behind a `robots.txt` disallow | Crawling | 05 |
| 5 | A page that is not linked anywhere | Content discovery | 05 |
| 6 | A key inside a JavaScript bundle | Reading JavaScript | 05 |
| 7 | A response header on a hidden vhost | Vhost discovery | 04 |
| 8 | The `origin` URL in an exposed `.git` directory | Exposed version control | 05 |

A flag looks like `FLAG{dns_txt_a1b2c3d4e5f6}`. When you have all eight, go to
page 09 and do the timed run.

## Findings that are not flags

Worth writing down all the same, because on a real job these are the report:

- The `Server` header names the web server and its version.
- `X-Powered-By` names the application and its version.
- `/.well-known/security.txt` exists and gives a contact.
- A PDF in `/public` carries author and software metadata.
- The site lists three staff email addresses, so you can work out the pattern.
- `robots.txt` disallows three paths, and disallowing is not protecting.
- `sitemap.xml` exists and is incomplete.
- The vhost baseline: known hosts return 200, unknown hosts return 404.

A finding is anything you can explain: what you did, what you saw, what it means,
and how it would be fixed.

## Do not read the answers

The generator writes the flags into `generated/`. Reading it is the same as
reading the answers at the back of the book, and it turns a recon exercise into a
`cat` exercise. Find them through the services, then compare.

## If something does not start

| Symptom | Cause and fix |
|---|---|
| `address already in use` on 15353 | Something on your machine holds that UDP port. Change it in `docker-compose.yml` and remember to use the new port |
| Connection refused on 8080 | Give it a few seconds, or check `docker compose ps` |
| `init` exits with an error | Run `docker compose logs init` and read it |
| DNS returns nothing | Check you are using `-p 15353` with dig, or `-port=15353` with nslookup |
| Everything returns 404 | You forgot the `Host` header |

## Clean up

```bash
docker compose down
docker compose run --rm init 2>/dev/null || true
```

The containers are bound to `127.0.0.1` on purpose, so nothing in the range is
reachable from outside your machine.

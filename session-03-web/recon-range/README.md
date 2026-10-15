# The recon range

A small target you run on your own machine. It exists because the rooms cover the
passive techniques well, but almost nothing free lets you practise DNS zone
transfers, vhost discovery, crawling a messy site, or chaining the tools into a
pipeline.

This is that target. It plants **seven flags**, one for each technique, and the
flag values are generated fresh on every run so they are never in this repo.

## Run it

```bash
cd session-03-web/recon-range
./up.sh
```

Requires Docker. First run pulls two small images. When it finishes:

| Service | Address | How to reach it |
|---|---|---|
| DNS | `127.0.0.1:15353` | `dig @127.0.0.1 -p 15353 recon.lab ANY` |
| Web | `127.0.0.1:8080` | `curl -H "Host: www.recon.lab" http://127.0.0.1:8080/` |

Both are bound to `127.0.0.1` on purpose, so nothing here is reachable from
outside your machine.

Stop it with `./down.sh`, or `./down.sh --clean` to also throw away the flags.

**The web server needs a Host header.** That is deliberate: it is how virtual hosts
work, and finding the hidden one is one of the exercises.

## Do not open the generated folder

`up.sh` writes the site and the DNS zone into `generated/`. Every answer is in
there. Reading it is the same as reading the answers at the back of the book, and
it turns a recon exercise into a `cat` exercise. Find the flags through the
services, then compare.

## The seven flags

Find them in this order. The technique column is the page in this module that
teaches it.

| Flag | Where it hides | Technique | Page |
|---|---|---|---|
| 1 | A TXT record on the zone | DNS records | 03 |
| 2 | A record only visible in a full zone dump | Zone transfer (AXFR) | 03 |
| 3 | An HTML comment on a page | Reading source | 05 |
| 4 | A file inside a directory that robots.txt disallows | Crawling, robots.txt | 05 |
| 5 | A page that is not linked anywhere | Content discovery | 05 |
| 6 | A key inside a JavaScript bundle | Reading JavaScript | 05 |
| 7 | A response header on a hidden virtual host | Vhost discovery, fingerprinting | 04 |

A flag looks like `FLAG{dns_txt_a1b2c3d4e5f6a7b8}`. When you have all seven, the
assessment page tells you what to do with them.

## What else is in there

Not everything is a flag. There are also things worth noticing and writing down:

- The server version is visible in the `Server` header.
- An application version is visible in `X-Powered-By`.
- `/.well-known/security.txt` exists.
- `/.git/HEAD` exists, which on a real target would be a serious finding.
- `robots.txt` disallows three paths, and disallowing is not protecting.
- A `sitemap.xml` exists and is deliberately incomplete.

A finding is anything you can explain: what you did, what you saw, what it means,
and how it would be fixed. The seven flags are the score, the findings are the
work.

## If something does not start

- **DNS port already in use.** Something on your machine is using UDP 15353.
  Change the port in `docker-compose.yml` and in the `up.sh` output line.
- **Connection refused on 8080.** Give it a few seconds, nginx starts fast but not
  instantly.
- **`dig` returns nothing.** Check the containers are up with
  `docker compose ps`, and that you are using `-p 15353`.

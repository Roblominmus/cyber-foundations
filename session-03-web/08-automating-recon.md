# 08: Automating recon

[Previous: Web archives](07-web-archives.md) | [Session index](README.md) | [Next: Skills assessment](09-skills-assessment.md)

## Why automate

By now you have done each step by hand. Automation is not a different skill, it is
the same steps in a script so that you can run them against a bigger target, and
run them again next week without starting over.

Automate last, not first. If you automate something you do not understand, you get
a big output file you cannot read and a report you cannot defend.

## The pipeline

The standard chain, in order. Each stage eats the previous stage's output.

```
names      subfinder, crt.sh        ->  a list of hostnames
   |
alive      httpx                    ->  which ones actually respond, with headers
   |
content    katana, ffuf             ->  URLs, directories, parameters
   |
screens    eyewitness, aquatone     ->  a visual index of what you found
   |
issues     nuclei                   ->  known misconfigurations and exposures
```

The last stage, `nuclei`, is the one people reach for first. Do not. It is a
scanner, and a scanner on an unverified host list produces noise. Do the first
three stages, then run `nuclei` on hosts you have confirmed are alive and in scope.

## A worked script

```bash
#!/usr/bin/env bash
# recon.sh <domain>   run from an empty folder
set -euo pipefail
D="$1"; mkdir -p "$D"; cd "$D"

echo "[*] subdomains"
subfinder -d "$D" -silent | sort -u > subs.txt
curl -s "https://crt.sh/?q=%25.$D&output=json" \
  | python3 -c "import sys,json;[print(n) for e in json.load(sys.stdin) for n in e['name_value'].split('\n')]" \
  | sed 's/\*\.//' | sort -u >> subs.txt
sort -u subs.txt -o subs.txt
wc -l subs.txt

echo "[*] which are alive"
httpx -l subs.txt -silent -status-code -title -tech-detect -o alive.txt
cat alive.txt

echo "[*] crawl what is alive"
awk '{print $1}' alive.txt | while read -r u; do
  katana -u "$u" -d 2 -jc -silent 2>/dev/null || true
done | sort -u > urls.txt
wc -l urls.txt

echo "[*] interesting shapes"
grep -iE 'admin|login|api|upload|backup|\.zip|\.sql|\.bak|\.env|config' urls.txt > interesting.txt || true
cat interesting.txt

echo "[*] done. Read alive.txt and interesting.txt by hand."
```

Run it as `bash recon.sh example.com`. Read the output by hand. The script's job is
to remove the typing, not the thinking.

## Rules that keep you out of trouble

- **Scope first.** Confirm every host in your list is in scope. A subdomain you
  found by certificate transparency may be owned by a third party, and scanning it
  could be an offence.
- **Rate limit.** `ffuf` and `nuclei` will happily send thousands of requests a
  second. Add `-rate-limit` and `-t` limits. Overloading a client's site is a real
  way to end an engagement badly.
- **Not everything wants to be scanned.** Some hosts are production, some are
  fragile legacy systems. If in doubt, ask.
- **Keep the raw output.** Every finding must be traceable to a command and a
  timestamp. Store the tool output next to your notes.

## Store the results properly

```
example.com/
  subs.txt          raw subdomain list
  alive.txt         httpx output
  urls.txt          crawled URLs
  interesting.txt   filtered for review
  notes.md          your written findings, with dates
  evidence/         screenshots
```

Six months later, on the next engagement, that folder is worth more than the
tools.

## Practise

### On the range: automate the whole thing

The range has seven flags. Do not find them by hand this time. Write the pipeline
and let it find them, then verify by hand only what the pipeline reports.

Your target:

- DNS on `127.0.0.1:15353`, zone `recon.lab`
- Web on `127.0.0.1:8080`, with `Host` headers for the vhosts

Adapt the script from earlier in this page. Points to note:

- `subfinder` and `httpx` expect real DNS and hostnames. Against the range, use
  `dig` with `-p 15353` in a loop for the DNS stage, and `curl -H "Host: ..."`
  for the web stage. Do not be precious about the tools, the stages are what
  matter.
- The wordlist to brute force subdomains against the zone.
- For the web stage, fuzz the `Host` header, not the path, to find the hidden
  vhost.
- For the content stage, run `ffuf` against the paths you found in `robots.txt`
  and against a directory wordlist.

**Deliverable.** One script, `recon-range.sh`, that:

1. Dumps the zone and prints every record type it found.
2. Lists the names that resolve.
3. Prints the response headers for each vhost it discovers.
4. Runs a content discovery pass and prints anything that is not a 404.
5. Prints every `FLAG{...}` string it saw, with the command that produced it.

Then answer:

1. How many of the seven flags did your script find without you touching it?
2. For each flag it missed, why did it miss it, and what would you add?
3. Which stage of your pipeline produced the most findings?
4. Why should `nuclei` still not be the first stage, even on your own range?

### Room task

**[TryHackMe: ffuf](https://tryhackme.com/room/ffuf)** (free) covers the content
discovery stage properly, including how to filter output so it is readable. That
filtering is the difference between a useful run and a wall of text.

**Questions to answer in your notes:**

- Why is the pipeline order names, then alive, then content, and not the reverse?
- What breaks in your script if you point it at a domain you do not control?
- Which part of the run would you still want a human to look at, and why?

[Previous: Web archives](07-web-archives.md) | [Session index](README.md) | [Next: Skills assessment](09-skills-assessment.md)

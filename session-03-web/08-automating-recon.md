# 08: Automating recon

[Previous: Web archives](07-web-archives.md) | [Session index](README.md) | [Next: OWASP Top 10 to PortSwigger](09-owasp-top-10-to-portswigger.md)

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

Automation needs tools, so this is the one page where a terminal genuinely helps.
The thinking is the exercise, and you can do that anywhere.

### Task 1: write the pipeline, in order

Here is the chain, empty. Fill in each stage with the technique from the earlier
pages, and name the free tool that does it.

| Stage | What it produces | Tool |
|---|---|---|
| 1. Names | Every hostname you know about | |
| 2. Alive | Which of them answer, with headers | |
| 3. Content | URLs, directories, files | |
| 4. Review | The things a human should look at | |

1. Why is the order names, then alive, then content, and not the reverse?
2. Which stage would you run first if you had one hour on a new target, and why?
3. Why would you not start with a vulnerability scanner?

### Task 2: run the stages by hand

Pick the domain you have been using for this module and do stages 1 to 4
manually, in the browser and with `curl`, writing down the command or the click
that produced each result.

```bash
# stage 1, names: certificate transparency, in the browser
#   https://crt.sh  ->  search %.your-domain

# stage 2, alive: what the host says about itself
curl -I https://your-domain

# stage 3, content: the paths that matter
curl -s https://your-domain/robots.txt
curl -s https://your-domain/ | grep -oE 'href="[^"]+"|src="[^"]+"'

# stage 4, review: read what you collected
```

`curl` ships with Windows 10 and later, macOS and Linux. On Windows use
`curl.exe` if plain `curl` opens something else.

### Task 3: write the script

Write the pipeline as a script you could run next time on a new target. Rules it
must follow:

- Names, then alive, then content, in that order.
- A rate limit on anything that sends many requests.
- Output to one file per stage, so any finding can be traced back.
- It refuses to run against a domain that is not in a list you pass it, so you
  cannot point it at something out of scope by accident.

If you have a Linux or macOS terminal, run it against a domain you own. If you do
not, the script and the reasoning are the deliverable.

### Deliverable

1. The filled-in pipeline table.
2. Your script, or your manual command list for the four stages.
3. One paragraph: which stage found the most, and which stage needed a human.

### Room task

**[TryHackMe: ffuf](https://tryhackme.com/room/ffuf)** (free) covers the content
discovery stage properly, including how to filter output so it is readable.

**Questions for your notes:**

- Why is the pipeline order names, alive, content, and not the reverse?
- What breaks if you point a pipeline at a domain you do not control?
- Which part of a run would you still want a human to look at?

[Previous: Web archives](07-web-archives.md) | [Session index](README.md) | [Next: OWASP Top 10 to PortSwigger](09-owasp-top-10-to-portswigger.md)

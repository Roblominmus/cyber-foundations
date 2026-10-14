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

**Task.** Run the pipeline above against a domain you have permission to test. If
you do not have one, use the domain of a site you own, or set up
[OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) locally and run the
content discovery stages against `127.0.0.1`.

Then do the room:

[TryHackMe: ffuf](https://tryhackme.com/room/ffuf) (free) covers the content
discovery stage properly, including how to filter the output so it is readable.
That filtering is the difference between a useful run and a wall of text.

**Questions to answer in your notes:**

1. Why is `nuclei` the last stage and not the first?
2. What happens to your results if you scan a host list that includes a third
   party's domain?
3. Which single stage of the pipeline found the most that you would not have found
   by hand?

**Deliverable for this page:** your script, and one run's output folder, committed
to your own notes. Not to this repo. This repo has no place to put your results,
and your findings from a real target should not be published.

[Previous: Web archives](07-web-archives.md) | [Session index](README.md) | [Next: Skills assessment](09-skills-assessment.md)

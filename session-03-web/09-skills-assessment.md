# 09: Skills assessment

[Previous: Automating recon](08-automating-recon.md) | [Session index](README.md) | [Next: OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md)

No new techniques here. This is the page where you do all of it against a target
that has real answers, and write it up.

## Part 1: the range, all seven flags

Start the range and collect every flag. This part is timed.

```bash
cd recon-range && ./up.sh
```

Rules:

- Time yourself, and note the time when you get the seventh flag.
- Any tool is allowed. You may not open `generated/`. If you do, you have not done
  the exercise.
- Record the exact command that produced each flag, not just the flag.

| Flag | Technique | Command that produced it |
|---|---|---|
| 1 | | |
| 2 | | |
| 3 | | |
| 4 | | |
| 5 | | |
| 6 | | |
| 7 | | |

The command column is the point. A flag with no command behind it is a guess, and
on a real job a finding with no evidence is not a finding.

Aim to be under 30 minutes with this module open. If it took much longer, write
down which flag cost you the most time and why.

## Part 2: the OSINT investigation

[TryHackMe: OhSINT](https://tryhackme.com/room/ohsint) (free) gives you a single
image and asks you to find out everything about the person behind it. It has real
flags, and it is entirely passive, so nothing you do can be seen.

It pulls together nearly every page in this module:

| What you will use | From which page |
|---|---|
| Reading metadata and visual clues | 04, fingerprinting |
| Searching with operators | 06, search engine discovery |
| The Wayback Machine for removed content | 07, web archives |
| Public records and social media | 06, search engine discovery |
| Patience and note taking | 01, recon basics |

Work it with your notes file open. Record the search query that gave you each
answer, not just the answer.

**The flag is the room's, not ours.** We do not publish it, and you should not go
looking for a writeup until you have spent a real hour on it. When you are stuck,
the useful move is to re-read your own notes and ask what you have not tried yet.

## Part 3: recon against a real application

Run [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) locally:

```bash
docker run --rm -p 3000:3000 bkimminich/juice-shop
```

Now do a full recon pass against `http://127.0.0.1:3000` and record everything.
Juice Shop is deliberately full of discoverable things, and it is yours, so you can
look as hard as you like.

Work through this list and write down each answer:

1. **Fingerprint.** What are the response headers? What does `whatweb` report? Is
   there a `Server` or `X-Powered-By` header, and what does the absence of one
   tell you?
2. **robots.txt.** Fetch it. List every disallowed path.
3. **The /ftp folder.** Enumerate it. It contains a file listing and several files
   that should not be public. Name them and say what each one leaks.
4. **Source and JavaScript.** Pull the main page, list the JavaScript bundles, and
   grep one for `/rest/` and for credential looking strings. List the API endpoints
   you can find that the user interface never offers you.
5. **The sitemap.** Is there one? What does it reveal?
6. **Directory discovery.** Run `ffuf` against the app with a wordlist and record
   anything interesting. Do not run it fast, it is your own machine but the habit
   matters.

## Part 4: the write up

This is the deliverable, and it is the point of the whole module. A recon report,
one page, with these sections:

```
TARGET:      what you looked at, and the scope you were given
METHOD:      the tools and the order you used them in
FINDINGS:    one entry per finding. What you did, what you saw,
             what it means, and how it would be fixed.
EVIDENCE:    the command and its output, or a screenshot
LIMITATIONS: what you did not check, and why
```

One finding, written properly, looks like this:

```
FINDING: Directory listing exposed at /ftp
DID:     Read robots.txt, which disallowed /ftp. Fetched the path directly.
SAW:     A directory listing containing backup files, including a
         confidential document and a backup archive.
MEANS:   Anyone on the internet can read these files. The path was hidden
         from crawlers but not protected, so it is discoverable and public.
         This is an information disclosure issue and a starting point for
         further attacks.
FIX:     Remove the files from the web root. Do not rely on robots.txt for
         access control, it is a request, not a control. Require
         authentication on any path holding non public files.
```

Do that for at least four findings. The "means" and "fix" parts are the ones that
separate a pentest report from a screenshot collection, so do not skip them.

## What you should be able to do now

- Run passive recon on a domain without touching the target.
- Enumerate subdomains from several sources and explain which source found what.
- Fingerprint a web application from its own responses.
- Find exposed files and paths that nobody linked.
- Chain the steps into a script, and explain why each stage is in that order.
- Write a finding that somebody could act on.

If you cannot do one of those, go back to that page. The pages are short on
purpose, so re-reading is cheap.

[Previous: Automating recon](08-automating-recon.md) | [Session index](README.md) | [Next: OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md)

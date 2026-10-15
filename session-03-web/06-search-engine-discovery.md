# 06: Search engine discovery

[Previous: Crawling](05-crawling.md) | [Session index](README.md) | [Next: Web archives](07-web-archives.md)

## The idea

Search engines have already crawled a large part of the internet and kept copies.
You are not searching the live target, you are searching what the target showed
the world, including pages it has since removed. Done well this is completely
passive: the target never sees you.

## Operators worth memorising

| Operator | Does | Example |
|---|---|---|
| `site:` | Restrict to one domain | `site:example.com` |
| `inurl:` | Term appears in the URL | `site:example.com inurl:admin` |
| `intitle:` | Term appears in the page title | `intitle:"index of"` |
| `intext:` | Term appears in the body | `intext:"sql syntax"` |
| `filetype:` | Specific file extension | `site:example.com filetype:pdf` |
| `ext:` | Same idea, slightly different syntax | `site:example.com ext:sql` |
| `cache:` | Google's stored copy | `cache:example.com` |
| `-` | Exclude | `site:example.com -inurl:www` |
| `OR` / `|` | Either | `site:example.com (inurl:dev OR inurl:test)` |
| `""` | Exact phrase | `"index of /backup"` |

Combine them. `site:example.com (ext:log OR ext:bak OR ext:old)` is one query that
often finds something.

## What you are hunting for

- **Directory listings.** `intitle:"index of" site:example.com` finds servers that
  will happily list a folder to anyone.
- **Exposed documents.** `filetype:pdf`, `filetype:xlsx`, `filetype:docx` on a
  company domain regularly turns up internal documents.
- **Backup and config files.** `ext:bak`, `ext:old`, `ext:sql`, `ext:env`.
- **Login and admin panels.** `inurl:login`, `inurl:admin`, `inurl:portal`, which
  also multiplies your entry points.
- **Verbose errors.** `intext:"Warning: mysql"`, `intext:"stack trace"`.
- **Subdomains nobody linked.** `site:*.example.com -inurl:www`.

The Google Hacking Database collects these queries by category and is worth
browsing once, then keeping as a reference.

## GitHub and paste sites

Developers leak more than websites do.

- Search GitHub for the company name plus `password`, `api_key`, `secret`,
  `BEGIN RSA PRIVATE KEY`, or an internal hostname.
- Old forks and deleted repositories often still exist in someone's fork. The
  Wayback Machine and public code search tools help here.
- Paste sites and leak forums are outside the scope of this course. Note that
  checking them may be illegal or against your agreement, so do not, unless it is
  explicitly in scope.

GitHub search also has operators: `org:`, `user:`, `path:`, `filename:`, and
`language:`. `org:example filename:.env` is a good first query on a real
engagement, if the organisation has a public presence.

## The habit

Write down the query that found each thing. On a report, "we found X" is much
weaker than "we found X with this query, on this date, and here is the link".
Search results change, so the date matters.

## Practise

This page is all browser work. No tools, no operating system problems, and it
works if you are reading this on GitHub with nothing installed. That is not a
downgrade: this is genuinely how the technique is done.

### Task 1: learn the operators

Run every one of these against a domain you are allowed to look at, and write down
what each one does to the result set. Note that Google is not the only engine;
Bing and DuckDuckGo support most of these too, with slightly different syntax.

| Query | What you are looking for |
|---|---|
| `site:example.com` | Every indexed page on that domain |
| `site:example.com -inurl:www` | Pages, excluding the main host, which hints at subdomains |
| `site:example.com inurl:admin` | Admin panels |
| `site:example.com inurl:login` | Login pages |
| `site:example.com filetype:pdf` | Documents, which often leak more than pages |
| `site:example.com (ext:sql OR ext:bak OR ext:old OR ext:env)` | Files that should not be public |
| `intitle:"index of" site:example.com` | Directory listings |
| `intext:"sql syntax near" site:example.com` | Verbose database errors |
| `site:example.com inurl:api` | API endpoints |

### Task 2: the worksheet

Against your chosen domain, try to find one of each. If you cannot find one, write
that down too, because "searched and found nothing" is a result.

| Target | Found? | The exact query that found it |
|---|---|---|
| A directory listing | | |
| A file with an extension that should not be public | | |
| A login or admin page not linked from the site | | |
| A subdomain the main site never mentions | | |
| A document that looks internal | | |
| A page that reveals an error message | | |

The query column is the point. On a report, "we found X" is weak. "We found X with
this query, on this date, and here is the link" is a finding.

### Task 3: the Google Hacking Database

Browse the [Google Hacking Database](https://www.exploit-db.com/google-hacking-database)
once. It is a categorised list of exactly these queries. Find three entries you
would not have thought of, and try them against your domain.

### Task 4: code search, in a browser

Developers leak more than websites do.

1. On GitHub, search your chosen organisation or project name together with
   `password`, `api_key`, `secret`, or `BEGIN RSA PRIVATE KEY`.
2. Use the code search operators: `org:`, `user:`, `path:`, `filename:`,
   `language:`. For example `org:example filename:.env`.
3. Note anything that looks like a real credential. Do not use it. The point is
   that it was findable.

Do not go looking at paste sites or leak forums. That may be illegal or against
your agreement, and it is out of scope for this course unless a client puts it in
writing.

### Room task

**[TryHackMe: Search Skills](https://tryhackme.com/room/searchskills)** (free) is
the room for this page. Search engines, operators, and specialised search
services, with questions and real answers. Do it with this page open.

Then the search engine task in
**[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)**
(free), which does dorking against a target.

**Questions for your notes:**

- Why does a search engine show you a page that no longer exists on the target?
- What does `site:` actually restrict, and what does it not?
- Why should every finding record the date it was found?

[Previous: Crawling](05-crawling.md) | [Session index](README.md) | [Next: Web archives](07-web-archives.md)

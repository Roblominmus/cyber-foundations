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

**Room task.** [TryHackMe: Search Skills](https://tryhackme.com/room/searchskills)
(free). This is the room for this page. It covers search engines, operators and
specialised search services, and it has questions with real answers. Do it
properly, with the operators above in front of you.

Then the search engine task inside
[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)
(free), which uses dorking against a target alongside the other passive
techniques.

**Real world task.** Using operators only, and only against domains you are
allowed to look at, try to find each of the following. If you cannot find one on
your target, say so in your notes, because "searched and found nothing" is a
finding too.

1. A directory listing on the domain.
2. Any file with an extension that should not be public: `sql`, `bak`, `old`,
   `log`, `env`.
3. A login or admin page that is not linked from the main site.
4. A subdomain that the main site never mentions.
5. A public document that looks internal.

**Questions to answer in your notes:**

- Why does a search engine show you a page that no longer exists on the target?
- What does `site:` actually restrict, and what does it not?
- Why should you record the date of every search result in a report?

[Previous: Crawling](05-crawling.md) | [Session index](README.md) | [Next: Web archives](07-web-archives.md)

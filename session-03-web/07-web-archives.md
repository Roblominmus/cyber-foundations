# 07: Web archives

[Previous: Search engine discovery](06-search-engine-discovery.md) | [Session index](README.md) | [Next: Automating recon](08-automating-recon.md)

## What an archive gives you

The Wayback Machine and similar services have been taking snapshots of the web
for decades. For recon, that means you can see what a site looked like years ago,
and, more usefully, **which URLs existed then and do not exist now**.

Removed endpoints are gold. Somebody removed the link, not necessarily the code.
The old admin panel, the old API version, the old upload page and the old backup
folder are frequently still live and still unpatched, just unlinked.

## The Wayback Machine by hand

Open `https://web.archive.org/` and paste a URL. Then use the calendar view to
pick old snapshots. Things worth looking at in an old snapshot:

- Navigation menus, which list pages that may no longer be linked.
- Job adverts, which name internal technologies, and sometimes internal hostnames.
- Old contact pages, which name people who may still have accounts.
- Old JavaScript files, which may contain keys that have never been rotated.
- Old terms and policy pages, which sometimes name systems and vendors.

## The Wayback CDX API

Faster than clicking, and scriptable. The CDX API returns the list of everything
the archive holds for a domain.

```bash
# every archived URL for a domain, just the URLs
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com*&output=text&fl=original&collapse=urlkey" | head -50

# count them
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com*&output=text&fl=original&collapse=urlkey" | wc -l

# everything archived under one path, to hunt removed endpoints
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com/admin*&output=text&fl=original&collapse=urlkey"
```

`collapse=urlkey` removes duplicates. `fl=original` asks for just the URL column.
Add `&from=2015&to=2019` to restrict to a date range, which is useful when you
want to see what existed before a rebuild.

Then filter the output for the interesting shapes:

```bash
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com*&output=text&fl=original&collapse=urlkey" \
  | grep -iE 'admin|login|api|backup|old|test|dev|staging|upload|config|\.zip|\.sql|\.bak'
```

## Tools that wrap the archive

```bash
# collect archived URLs
waybackurls example.com | sort -u > archived.txt

# or combine several sources including the archive
gau example.com | sort -u > archived.txt
```

Either way you end up with a list of URLs from the past. The valuable next step is
checking which of them still respond today.

```bash
cat archived.txt | httpx -status-code -title -mc 200,301,302,401,403
```

Anything that returns 200 and looks like it should not be public is a finding.

## A note on archive.today

`archive.today` keeps snapshots too, including pages that other archives drop on
request. When something is missing from the Wayback Machine, it is worth checking
there as well.

## Practise

This page has no room, so the practice is a real run against a domain you are
allowed to investigate. Do all five steps and write them up.

1. Pick your target domain.
2. Pull every archived URL:

```bash
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com*&output=text&fl=original&collapse=urlkey" | sort -u > archived.txt
wc -l archived.txt
```

3. Filter for the interesting shapes using the grep above. Save the filtered list.
4. Take the filtered list and probe it to see what still exists today:

```bash
cat filtered.txt | httpx -status-code -title -mc 200,301,302,401,403
```

5. For anything that still answers, open it and decide: is this supposed to be
   public? Write one sentence per URL saying why or why not.

**Questions to answer in your notes:**

- How many archived URLs did you find in total, and how many looked interesting?
- How many of the interesting ones still respond today?
- Why is "removed from the menu" not the same as "removed from the server"?
- What would you check in an archived JavaScript file, and why would an old key
  still be dangerous?

**Deliverable for this page:** a short list of old URLs that still respond, each
with a sentence on the risk. That list, with dates and evidence, is exactly the
shape of a real recon finding.

[Previous: Search engine discovery](06-search-engine-discovery.md) | [Session index](README.md) | [Next: Automating recon](08-automating-recon.md)

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

Browser first, then one API call. Both work on any operating system, and both work
if you are reading this on GitHub, so there is nothing to install.

### Task 1: the Wayback Machine by hand

1. Open [web.archive.org](https://web.archive.org/).
2. Paste the address of a domain you are allowed to look at.
3. Pick a snapshot from several years ago and open it.
4. Look for each of these in the old version, and note what changed:

| Look at | Why |
|---|---|
| The navigation menu | Pages that existed then and may still exist now, unlinked |
| Job adverts | They name internal technology, sometimes internal hostnames |
| The team or contact page | People who may still have accounts |
| Old JavaScript files | Keys that may never have been rotated |
| Old policy or terms pages | They name systems and vendors |

### Task 2: the CDX API

Faster than clicking, and it gives you the whole list at once. `curl` is on all
three systems.

**Linux or macOS:**

```bash
curl -s "http://web.archive.org/cdx/search/cdx?url=example.com*&output=text&fl=original&collapse=urlkey" | sort -u > archived.txt
wc -l archived.txt
```

**Windows PowerShell:**

```powershell
curl.exe -s "http://web.archive.org/cdx/search/cdx?url=example.com*&output=text&fl=original&collapse=urlkey" |
  Sort-Object -Unique | Set-Content archived.txt
(Get-Content archived.txt).Count
```

Replace `example.com` with your domain. `collapse=urlkey` removes duplicates and
`fl=original` asks for just the URL column. Add `&from=2015&to=2019` to look at one
period, which is useful when a site was rebuilt.

### Task 3: filter for the interesting shapes

```bash
grep -iE "admin|login|api|backup|old|test|dev|staging|upload|config|\.zip|\.sql|\.bak" archived.txt > interesting.txt
wc -l interesting.txt
```

On Windows PowerShell:

```powershell
Select-String -Path archived.txt -Pattern "admin|login|api|backup|old|test|dev|staging|upload|config|\.zip|\.sql|\.bak" |
  ForEach-Object { $_.Line } | Set-Content interesting.txt
```

### Task 4: which of them still exist today

This is the step people skip, and it is the step that produces findings. A URL
from 2016 that still answers today is a live, unlinked, possibly unpatched page.

**Linux or macOS:**

```bash
while read -r u; do
  code=$(curl -s -o /dev/null -w "%{http_code}" -L --max-time 10 "$u")
  [ "$code" = "200" ] && echo "STILL LIVE: $u"
done < interesting.txt
```

**Windows PowerShell:**

```powershell
Get-Content interesting.txt | ForEach-Object {
  $c = curl.exe -s -o NUL -w "%{http_code}" -L --max-time 10 $_
  if ($c -eq "200") { "STILL LIVE: $_" }
}
```

### Deliverable

A list of old URLs that still respond, each with one sentence on the risk:

```
URL: https://example.com/old-admin/
First archived: 2016
Status today: 200, login form
Risk: a login page that is no longer linked from anywhere and has had no
      visible changes since 2016. Authentication on it is unknown.
```

That list, with dates and evidence, is the shape of a real recon finding.

**Questions for your notes:**

- How many archived URLs did you find in total, and how many looked interesting?
- How many of the interesting ones still respond today?
- Why is "removed from the menu" not the same as "removed from the server"?
- What would you check in an archived JavaScript file, and why is an old key
  still dangerous?

[Previous: Search engine discovery](06-search-engine-discovery.md) | [Session index](README.md) | [Next: Automating recon](08-automating-recon.md)

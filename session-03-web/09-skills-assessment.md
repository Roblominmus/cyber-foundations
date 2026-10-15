# 09: Skills assessment

[Previous: Automating recon](08-automating-recon.md) | [Session index](README.md) | [Next: OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md)

No new techniques here. This is the page where you do all of it against a target
that has real answers, and write it up.

## Part 1: the recon run

Everything you need is in a browser. No installs.

**Your target:** [demo.testfire.net](http://demo.testfire.net/), IBM's deliberately
vulnerable banking application.

Work the whole module against it, in this order, and record the results:

| Step | Technique | What you did | What you found |
|---|---|---|---|
| 1 | Fingerprint the headers | | |
| 2 | Read `robots.txt` and the sitemap | | |
| 3 | Read the source of three pages | | |
| 4 | List the JavaScript files and read them | | |
| 5 | The well-known path pass | | |
| 6 | Find any document and read its metadata | | |
| 7 | Harvest email addresses | | |
| 8 | Look up the domain's WHOIS and DNS | | |
| 9 | Check certificate transparency for subdomains | | |
| 10 | Search the web for the domain with dorks | | |
| 11 | Check the archive for removed pages | | |

Then answer:

1. Which step produced the most findings?
2. Which finding would matter most to the owner, and why?
3. Which step would you skip if you had half the time?

### Part 1b: the room that has flags

[TryHackMe: OhSINT](https://tryhackme.com/room/ohsint) (free) gives you a single
image and asks you to find out everything about the person behind it. It has real
flags and it is entirely passive. Do it and collect them. We do not publish those
answers, they are the room's.

## Part 2: the write up

This is the deliverable, and it is the point of the whole module. One page:

```
TARGET:      what you looked at, and the scope you were given
METHOD:      the tools and the order you used them in
FINDINGS:    one entry per finding. What you did, what you saw,
             what it means, and how it would be fixed.
EVIDENCE:    the command, the click, or the screenshot
LIMITATIONS: what you did not check, and why
```

One finding, written properly:

```
FINDING: Login form posts credentials over plain HTTP
DID:     Opened the login page and read the form action in the page source.
SAW:     The form submits to an http:// address, not https://, so the
         username and password cross the network in clear text.
MEANS:   Anyone positioned on the network path, on the same wifi or at the
         ISP, can read the credentials. This is a confidentiality failure
         and it affects every user of the application.
FIX:     Serve the whole site over HTTPS and redirect HTTP to it. Mark the
         session cookie Secure and HttpOnly. Add HSTS once HTTPS is stable.
```

Do that for at least four findings. The "means" and "fix" parts are what separate
a report from a screenshot collection.

## Part 3: what you should be able to do now

- Run passive recon on a domain without touching the target.
- Find subdomains from several public sources and explain which found what.
- Fingerprint a web application from its own responses.
- Find paths, files and comments that nobody linked.
- Read a document's metadata and say why it matters.
- Write a finding that somebody could act on.

If you cannot do one of those, go back to that page. They are short on purpose, so
re-reading is cheap.

## Part 4: next, the attacking

Recon is half of Session 3. The other half is using what you found:

[OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md)

[Previous: Automating recon](08-automating-recon.md) | [Session index](README.md) | [Next: OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md)

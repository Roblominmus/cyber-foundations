# 02: WHOIS and email addresses

[Previous: Recon basics](01-recon-basics.md) | [Session index](README.md) | [Next: DNS and subdomains](03-dns-and-subdomains.md)

## What it is

WHOIS is a lookup service for domain registration data. You ask a registry or
registrar who owns a domain, and it tells you what it is allowed to tell you.
It is the first passive step on almost any external target, because it costs
nothing, touches the target not at all, and hands you names and infrastructure.

## The commands

```bash
# basic lookup
whois example.com

# ask a specific server
whois -h whois.iana.org example.com

# look up an IP instead of a domain, gives you the netblock owner
whois 203.0.113.10
```

## The fields worth reading

Not all of it matters. These do:

| Field | Why you care |
|---|---|
| Registrar | Who the domain is registered through |
| Creation and expiry date | Age of the domain, and whether it lapses soon |
| Updated date | Recent changes can mean a change of owner or infrastructure |
| Registrant organisation | The company behind it, when not redacted |
| Registrant email | A contact, sometimes personal, sometimes a role address |
| Name servers | Where DNS is hosted, which hints at the provider |
| Status codes | `clientTransferProhibited` and similar tell you the lock state |
| Abuse contact | Who to report to, and sometimes a real mailbox pattern |

Name servers are the most useful for recon. If the name servers belong to a
hosting company, the domain is probably hosted there too. If they belong to
Cloudflare, the real origin IP is hidden behind a CDN and you will have to work
harder for it.

## What it will not give you

Since GDPR, most registrars redact the registrant name, address, phone and email
for individuals. You will often see "REDACTED FOR PRIVACY" or a proxy service
such as "Whois Privacy Protection Service". That is normal, not a mistake on your
part.

Redaction does not remove everything. The registrar, dates, name servers and
status are still there, and those are usually enough to move on.

## Going further than the basic lookup

- **Historical WHOIS** shows who owned the domain in the past. Useful when a
  domain has changed hands, or when the current record is redacted. Search for
  "historical whois" services.
- **Reverse WHOIS** searches by a field instead of a domain, for example every
  domain registered with the same email or organisation. That is how you find a
  company's other properties. Many of these services are paid, but some free
  tiers exist.
- **IP WHOIS** gives you the netblock and the hosting provider, which tells you
  whether the target is in a cloud, a datacentre, or a residential range.

## What this gives an attacker

- Extra domains belonging to the same organisation, each with its own attack
  surface. The main site is usually well looked after, the marketing site is not.
- Email addresses and naming patterns, which feed phishing and password spraying.
- Hosting provider and name servers, which tell you where to look for the real IP.
- Registration dates, which hint at how old the codebase is.

## Practise

WHOIS cannot be faked on your own machine, so this page is a browser page. That
means it works on any operating system, and it works if you are reading this on
GitHub with nothing installed.

### Task 1: WHOIS by hand, in a browser

Pick two domains you are allowed to look up: one large company and one small site.
Look each one up in a browser WHOIS service, for example
[who.is](https://who.is) or [lookup.icann.org](https://lookup.icann.org). Fill
this in for both:

| What | Large company | Small site |
|---|---|---|
| Registrar | | |
| Created | | |
| Expires | | |
| Name servers, and who runs them | | |
| Registrant, if not redacted | | |
| Status codes | | |

Then answer:

1. Which of the two gives away more, and why do you think that is?
2. Is the registrant redacted? If it is, what did you still get, and is that
   enough to keep going?

### Task 2: WHOIS from a terminal, if you have one

On **Linux or macOS**:

```bash
whois example.com
whois 203.0.113.10
```

On **Windows** there is no `whois` command. Use the browser service above, or run
it in WSL if you have it. There is no need to install anything for this page.

Read the output for: the registrar, the creation and expiry dates, the name
servers, and any `client*Prohibited` status codes. Name servers are the useful
one, because they tell you which company hosts the DNS.

### Task 3: harvest email addresses, on the range

This is the part that turns WHOIS into something useful. Start the range, then
collect every address the site gives you. `curl` works on all three systems
(use `curl.exe` on Windows if plain `curl` misbehaves):

```bash
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/about.html
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/
curl -s -H "Host: www.recon.lab" http://127.0.0.1:8080/.well-known/security.txt
```

1. List every email address you found.
2. Work out the naming pattern from the staff addresses.
3. Predict the addresses for two more names in the same pattern.
4. Check the same names against the staff password file in `/ftp/`, once you have
   found it on page 05. What does the overlap tell you?

The pattern is the finding. On a real engagement, a confirmed address pattern plus
a list of names is what password spraying is built on.

### Room task

The WHOIS tasks in
**[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)**
(free). Same technique against a real domain, with the room's own answers to check
yourself against.

**Questions to answer in your notes:**

- What does redaction hide, and what does it leave visible?
- Why are the name servers more useful than the registrant in most cases?
- What is the difference between forward WHOIS and reverse WHOIS?

[Previous: Recon basics](01-recon-basics.md) | [Session index](README.md) | [Next: DNS and subdomains](03-dns-and-subdomains.md)

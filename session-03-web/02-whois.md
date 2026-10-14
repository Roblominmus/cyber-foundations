# 02: WHOIS

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

**Room task.** Do the WHOIS tasks in
[TryHackMe: Passive Reconnaissance](https://tryhackme.com/room/passiverecon)
(free). The room asks you specific questions whose answers come straight out of
`whois` output, including a question about the registrar and one about when a
domain was created. Get the answers yourself rather than searching for them.

**Real world task.** Run `whois` against two domains you are allowed to look up,
one large company and one small site, and answer these in your notes:

1. Which registrar is each one with?
2. When was each created?
3. Which name servers does each use, and what company runs them?
4. Is the registrant redacted, and if not, what can you learn from it?
5. Which of the two hides more, and why do you think that is?

Compare the two answers. A large company has a legal and brand reason to control
its registration data, and often uses a corporate registrar with a proxy. A small
site frequently gives everything away, sometimes including a personal email. That
difference is the whole point of the exercise.

**Check:** the correct pattern in `whois` output is that redaction hides the
person, not the infrastructure. If you found the registrar, the dates and the
name servers, you did it right.

[Previous: Recon basics](01-recon-basics.md) | [Session index](README.md) | [Next: DNS and subdomains](03-dns-and-subdomains.md)

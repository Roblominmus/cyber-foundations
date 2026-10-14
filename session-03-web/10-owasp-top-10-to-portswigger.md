# 10: OWASP Top 10 to PortSwigger

[Previous: Skills assessment](09-skills-assessment.md) | [Session index](README.md)

## Why this page exists

The obvious instruction is "for each item in the OWASP Top 10, learn how to exploit
it". That wastes your time twice: PortSwigger has no labs for three of the ten, and
for the rest you would spend an hour working out which topic page and which labs
belong to which category.

So here is the mapping, already done. Use it as a shopping list.

## The mapping

OWASP Top 10, 2021 edition, against the PortSwigger Web Security Academy.

| OWASP category | PortSwigger topic | Labs |
|---|---|---|
| A01 Broken Access Control | [Access control vulnerabilities](https://portswigger.net/web-security/access-control), [CSRF](https://portswigger.net/web-security/csrf) | Yes |
| A02 Cryptographic Failures | none | No |
| A03 Injection | [SQL injection](https://portswigger.net/web-security/sql-injection), [OS command injection](https://portswigger.net/web-security/os-command-injection), [XXE](https://portswigger.net/web-security/xxe), [Server-side template injection](https://portswigger.net/web-security/server-side-template-injection) | Yes |
| A04 Insecure Design | [Business logic vulnerabilities](https://portswigger.net/web-security/logic-flaws) | Yes |
| A05 Security Misconfiguration | [Information disclosure](https://portswigger.net/web-security/information-disclosure), [HTTP Host header attacks](https://portswigger.net/web-security/host-header) | Yes |
| A06 Vulnerable and Outdated Components | none | No |
| A07 Identification and Authentication Failures | [Authentication](https://portswigger.net/web-security/authentication) | Yes |
| A08 Software and Data Integrity Failures | [Insecure deserialization](https://portswigger.net/web-security/deserialization) | Yes |
| A09 Security Logging and Monitoring Failures | none | No |
| A10 Server-Side Request Forgery | [SSRF](https://portswigger.net/web-security/ssrf) | Yes |

**Seven of the ten have labs.** That is the honest answer to "learn at least five",
and it is more than five.

## The three without labs, and what to do instead

Do not skip them, they matter. There is just nothing to click. Read, and write a
paragraph each in your own words.

**A02 Cryptographic Failures.** This is about data exposed because it was not
protected properly: passwords stored weakly, traffic in plain HTTP, secrets in
source, weak randomness. There is no lab because the flaw is usually in the code
rather than the request. Read the OWASP entry itself, which is free, and then look
at the PortSwigger [Authentication](https://portswigger.net/web-security/authentication)
labs on password reset and brute force, which overlap.

**A06 Vulnerable and Outdated Components.** This is the fingerprinting work from
page 04 of this module, turned into an attack. If you know a version, you look up
its vulnerabilities. The skill is version identification, and you already practised
it. Go back to [Fingerprinting](04-fingerprinting.md) and add: for each version you
find, search for known issues.

**A09 Security Logging and Monitoring Failures.** This is a defender's category,
and it is why the "how a defender would spot it" column exists in your Session 2
cheat sheet. There is nothing to exploit, so instead write down, for three of the
attacks you have already done, exactly what a defender would see in their logs. If
you cannot name the log line, the attacker wins the whole category.

## How to work a lab, so it actually sticks

For each category you pick:

1. **Read the topic page** before touching a lab. It is free, and it explains the
   mechanism. Skipping it turns the labs into guesswork.
2. **Do the Apprentice labs first, all of them.** They isolate one idea each.
3. **Then the Practitioner ones.** These are closer to real applications.
4. **Write it up** using the four questions: what you did, what you saw, what it
   means, how it is fixed.
5. **Tag it with the category**, so your notes are searchable by OWASP item later.

Do not chase the Expert labs. They are excellent and they are not the point of
this session.

## The deliverable

Pick **at least five** categories from the seven with labs. For each one:

- One short write-up of a lab you solved, with the request, the payload, why it
  worked, and the fix.
- One line naming the category, so it maps back to the table above.

Five categories, five write-ups, tagged. That is the whole exercise, and it is
enough to say you can find and exploit the common classes of web flaw rather than
just name them.

## A note on which edition to learn

The 2021 list is what most job adverts and reports still use, so learn it. But the
categories move, items get added and merged, and the code you meet in the wild will
not announce which version it is. Learn the mechanism of each flaw, not the number
in front of it. The number is just an index for the report.

[Previous: Skills assessment](09-skills-assessment.md) | [Session index](README.md)

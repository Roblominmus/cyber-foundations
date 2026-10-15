# 09: Skills assessment

[Previous: Automating recon](08-automating-recon.md) | [Session index](README.md) | [Next: OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md)

No new techniques here. This is the page where you do all of it against a target
that has real answers, and write it up.

## Part 1: the range, all eight flags

Start the range and collect every flag. This part is timed.

```bash
cd recon-range
docker compose down && docker compose up -d
```

The `down` first means fresh flag values, so you are not tempted by the ones you
saw while reading.

Rules:

- Time yourself, and note the time when you get the eighth flag.
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
| 8 | | |

Then the findings that are not flags. These carry as much weight:

| Finding | Where | Why it matters |
|---|---|---|
| Web server and version | | |
| Application and version | | |
| Author and software in the PDF | | |
| Email address pattern | | |
| Exposed `.git` directory | | |
| Vhost baseline behaviour | | |

The command column is the point. A flag with no command behind it is a guess, and
on a real job a finding with no evidence is not a finding.

Aim to be under 30 minutes with this module open. If it took longer, write down
which flag cost you the most time and why.

## Part 2: the OSINT investigation

[Previous: Automating recon](08-automating-recon.md) | [Session index](README.md) | [Next: OWASP Top 10 to PortSwigger](10-owasp-top-10-to-portswigger.md)

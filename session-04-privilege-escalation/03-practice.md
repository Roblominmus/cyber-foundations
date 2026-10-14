# 03: Practice

[Previous: Techniques](02-techniques.md) | [Session index](README.md)

The rooms give you a machine that is already broken in several ways. They do not
tell you how, and they do not teach the techniques. That is the correct division of
labour now that you have read pages 01 and 02: the rooms are for reps.

## The boxes

| Room | What it is | Cost |
|---|---|---|
| [TryHackMe: Windows PrivEsc](https://tryhackme.com/room/windows10privesc) | An intentionally misconfigured Windows VM with multiple routes to admin or SYSTEM. RDP is available. Credentials `user:password321` | Free |
| [TryHackMe: Windows PrivEsc Arena](https://tryhackme.com/room/windows10privescarena) | A second misconfigured Windows VM, leaning on Metasploit payloads in places | Free |

Both are deployable, so you get a real machine to attack over RDP.

**Do not confuse either of these with "Windows Privilege Escalation", which is a
different room and is Premium.** Similar names, different things. The two above are
the free training boxes.

Pick one and finish it before starting the other. Bouncing between two boxes is how
you learn neither.

## How to work a box

Loop through this, and do not skip the writing.

1. **Enumerate.** Run every command in [Enumeration](01-enumeration.md).
   Take notes. Do not exploit anything yet.
2. **List candidates.** From your output, write down every technique that could
   apply, using the priority list at the end of [Techniques](02-techniques.md).
   Rank them by how likely and how cheap they are.
3. **Test the cheapest first.** For each candidate, check the specific condition.
   Most will fail. That is normal and it is not wasted time.
4. **Exploit one.** When a condition holds, exploit it properly and get a shell as
   the higher privileged user.
5. **Prove it.** Run `whoami` and read a file you could not read before. On the
   room, capture the flag. Proof matters, "I think it worked" does not.
6. **Write it up.** Four questions: what you did, what you saw, what it means, how
   it is fixed.
7. **Reset and do the next one.** Most of these boxes have several independent
   routes. Getting one is not finishing the box.

## The checklist to keep open

```
[ ] whoami /priv                  any SeImpersonate, SeBackup, SeDebug, SeTakeOwnership
[ ] systeminfo + wmic qfe         build and patch level
[ ] net user / net localgroup administrators
[ ] netstat -ano                  anything listening on localhost only
[ ] sc query + wmic service       unquoted paths, service accounts, writable binaries
[ ] icacls / accesschk            can I write to a service directory or binary
[ ] schtasks /query /fo LIST /v   SYSTEM tasks with writable targets
[ ] AlwaysInstallElevated x2      both registry keys, HKLM and HKCU
[ ] reg query ...\Winlogon        DefaultPassword
[ ] reg query ...\Run             autoruns with writable targets
[ ] cmdkey /list                  saved credentials
[ ] PuTTY sessions in registry    saved sessions
[ ] PSReadLine history            credentials typed into PowerShell
[ ] unattend.xml / sysprep        install-time credentials
[ ] findstr /si password *.txt *.xml *.ini *.config
[ ] winPEAS                       as a second opinion, after the above
```

Print it, or keep it in a second window. Tick as you go, so you can see what you
have not tried rather than guessing at what you have.

## References worth bookmarking

These are the equivalents of GTFOBins, and they are free.

| Reference | What it is for |
|---|---|
| [LOLBAS](https://lolbas-project.github.io/) | Living Off The Land Binaries. Every built-in Windows binary you can abuse, and how. The Windows answer to GTFOBins |
| [HackTricks: Windows privilege escalation checklist](https://hacktricks.wiki/en/windows-hardening/checklist-windows-privilege-escalation.html) | The long checklist. Use it when you are stuck on a specific condition |
| [PayloadsAllTheThings: Windows privilege escalation](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Windows%20-%20Privilege%20Escalation.md) | Commands per technique, in one page |
| [GTFOBins](https://gtfobins.github.io/) | Linux, not this session, but learn it for Session 4's Linux half |

If you only bookmark one, make it LOLBAS. On a Windows box, abusing a signed
built-in binary is often quieter and more reliable than dropping a tool.

## Deliverable

For the box you complete:

- Your enumeration notes, in order, with the commands.
- The route you took, and the routes you found and did not take.
- A completed checklist showing what you ruled out.
- One write-up per route, in the four question format.

The "ruled out" part is worth as much as the win. On a real job you will not always
get to the top, and the report has to show what you checked and why it did not
work.

[Previous: Techniques](02-techniques.md) | [Session index](README.md)

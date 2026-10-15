# Session 04: Windows privilege escalation

**This module is Windows only.** Linux privilege escalation is a different skill
with different tooling, and it is already taught well for free, so there is no
point duplicating it here:

- Theory and practice together in
  [TryHackMe: Linux Privilege Escalation](https://tryhackme.com/room/linprivesc)
  (free), which walks the techniques step by step and then makes you use them.
- [GTFOBins](https://gtfobins.github.io/) as the reference for abusing binaries.
- The [HackTricks Linux privilege escalation checklist](https://hacktricks.wiki/en/linux-hardening/main-system-information/linux-privilege-escalation-checklist.html)
  for when you are stuck.

Everything below is Windows, because that is the half with no free teaching
material.

This is the learning half of Session 4. The other half is
[password attacks](../session-04-password-attacks/README.md).

## Why this folder exists

The Linux half is covered by a room that both teaches and trains. The Windows half
is not: the free Windows rooms are training grounds. They hand you a misconfigured
machine and say "get to SYSTEM", which is excellent practice and teaches you
nothing if you have not already learned the techniques.

So the theory is written out here, and the rooms are left to do what they are good
at, which is giving you reps.

## Read in order

| # | Page | What it covers |
|---|---|---|
| 01 | [Windows enumeration](01-enumeration.md) | What to run on a box you just landed on, and what you are looking for |
| 02 | [Windows privesc techniques](02-techniques.md) | Every common Windows privesc technique: how to spot it, how to exploit it |
| 03 | [Practice on the free rooms](03-practice.md) | The free rooms, a checklist to work through, and references |

## How this connects to the track

Read 01 and 02 first. Then go to the room with the checklist from 03 open, and
work it in order. The room will not tell you which technique to use, and that is
the point: finding the one misconfiguration out of twenty possible ones is the
actual skill.

## A word on scope and ethics

Privilege escalation is only ever done on a machine you are authorised to test.
Everything in this folder is aimed at the TryHackMe rooms, which are built for it,
and at lab machines you own. There is no other use for it.

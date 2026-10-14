# Session 04: Password attacks

This session is about credentials: how they are stored, how you identify what
you are looking at, and how you turn a hash back into a password.

## Read in this order

| Page | What it covers |
|---|---|
| [hashes.md](hashes.md) | What a hash is, salting, where hashes come from on a real job, and how to identify a hash type |
| [hashcat.md](hashcat.md) | Driving hashcat: modes, attack modes, rules, workflow |
| [john.md](john.md) | Driving John the Ripper, and the `*2john` tools for files |
| [wordlists.md](wordlists.md) | Where wordlists come from and how to build and mutate your own |
| [practice.md](practice.md) | Five exercises using the files in `practice/` |
| [solutions.md](solutions.md) | Answers and the exact commands. Look here after you try |

## What you need

- hashcat and john, both in Kali by default
- the wordlist and hash files in `practice/`

```bash
sudo apt install hashcat john hashcat-data
# hashid for identification
sudo apt install hashid
```

## How this connects to the track

The cracked hashes are the point of the exercise, not the goal of the session.
On a real job the order is: get a hash, identify it, pick the cheapest attack
that will work, then move on. Most of the skill is in the identify step and in
choosing a wordlist strategy, not in typing the hashcat command.

Practise cracking against the room in the track. This page teaches you the
tools so the room is not the first time you see them.

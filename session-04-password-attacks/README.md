# Session 04: Password attacks

Read these in order. Every page ends with a link to the next one, so if you just
keep clicking through you will cover the whole session in a sensible sequence.

| # | Page | What it covers |
|---|---|---|
| 01 | [Hashes, and how to identify them](01-hashes.md) | What a hash is, salting, where hashes come from on a job, identifying a type |
| 02 | [hashcat](02-hashcat.md) | Attack modes, masks, rules, options, workflow, the VM problem |
| 03 | [John the Ripper](03-john.md) | Driving john, and the `*2john` tools for files |
| 04 | [Wordlists and mutation](04-wordlists.md) | Sources, strategy, rules, building your own |
| 05 | [Exercise 1: identify the type](05-exercise-identify.md) | Look at eight hashes and classify them, no cracking |
| 06 | [Exercise 2: dictionary attack](06-exercise-dictionary.md) | Crack a mixed file with one wordlist |
| 07 | [Exercise 3: rules](07-exercise-rules.md) | Crack passwords that are not in the wordlist |
| 08 | [Exercise 4: salted and slow](08-exercise-salted.md) | md5crypt, sha512crypt and bcrypt, in both tools |
| 09 | [Exercise 5: close the loop](09-exercise-close-the-loop.md) | Identify, then crack, all eight |
| 10 | [Solutions](10-solutions.md) | Answers and exact commands. Read after you try |

## Reading this on GitHub, or cloning it

Both work. You do not need to clone anything to do the exercises.

**Reading on GitHub.** Every exercise page shows its hashes inline in a block you
can copy, and includes a one line command that writes them into a file for you.
Copy, paste, run. Nothing else needed.

**Cloned.** The same hashes, the wordlist and the rule file are already in the
`practice/` folder:

```bash
git clone https://github.com/Roblominmus/cyber-foundations
cd cyber-foundations/session-04-password-attacks
```

## What you need installed

hashcat and john ship with Kali. hashid does not.

```bash
sudo apt install hashcat john hashcat-data hashid
```

If hashcat refuses to start because it cannot find a device, that is normal in a
virtual machine and it is covered in [02-hashcat.md](02-hashcat.md).

## How this connects to the track

Cracking the practice hashes is the warm up, not the goal. On a real job the
order is: get a hash, identify it, pick the cheapest attack that will work, then
move on. Most of the skill is in the identify step and in choosing a wordlist
strategy, not in typing the command.

The room in the track is where you do this for real. These pages exist so the
room is not the first time you have seen the tools.

# Session 04: Password attacks

Read these in order. The pages alternate deliberately: read one, then use it. Every
tool page is immediately followed by the exercise that needs it, and nothing is
used before it is taught. If you just keep clicking Next you will cover the whole
session in the right sequence.

| # | Page | What it covers |
|---|---|---|
| 01 | [Hashes, and how to identify them](01-hashes.md) | What a hash is, salting, where hashes come from on a job, identifying a type |
| 02 | [Exercise 1: identify the type](02-exercise-identify.md) | Practise identification. Needs nothing but page 01, no cracking |
| 03 | [hashcat](03-hashcat.md) | Attack modes, masks, rules, options, workflow, the VM problem |
| 04 | [Exercise 2: dictionary attack](04-exercise-dictionary.md) | Your first crack, using the hashcat you just read |
| 05 | [Wordlists and mutation](05-wordlists.md) | Sources, strategy, and how rules turn words into passwords |
| 06 | [Exercise 3: rules](06-exercise-rules.md) | Crack passwords that are not words, using mutation |
| 07 | [John the Ripper](07-john.md) | The CPU tool, and the `*2john` family for pulling hashes out of files |
| 08 | [Exercise 4: salted and slow](08-exercise-salted.md) | md5crypt, sha512crypt and bcrypt, in both tools |
| 09 | [Exercise 5: close the loop](09-exercise-close-the-loop.md) | Identify, then crack, all eight, using everything so far |
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
virtual machine and it is covered in [the hashcat page](03-hashcat.md).

## How this connects to the track

Cracking the practice hashes is the warm up, not the goal. On a real job the
order is: get a hash, identify it, pick the cheapest attack that will work, then
move on. Most of the skill is in the identify step and in choosing a wordlist
strategy, not in typing the command.

The room in the track is where you do this for real. These pages exist so the
room is not the first time you have seen the tools.

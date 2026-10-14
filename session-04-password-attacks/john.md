# John the Ripper

john is the other half of the pair. Where hashcat wants a GPU and an explicit
hash type, john runs on the CPU, auto-detects many formats, and comes with a
family of tools for pulling hashes out of files.

Two reasons to reach for john:

1. You are in a VM with no GPU and hashcat will not start.
2. You have a file rather than a hash, and one of the `*2john` tools can read it.

## Basic use

```bash
john --wordlist=/usr/share/wordlists/rockyou.txt --format=Raw-MD5 hashes.txt
```

john works out the format itself in simple cases, but naming it explicitly saves
confusion and prevents it picking the wrong one. You will see `--format` called
`--format=` or just `--format` in different guides. Both work.

List everything it supports:

```bash
john --list=formats
```

## Useful flags

| Flag | Why |
|---|---|
| `--wordlist=FILE` | Dictionary attack |
| `--rules` | Apply mutation rules to the wordlist |
| `--format=NAME` | Force a format instead of guessing |
| `--show` | Print cracked results |
| `--incremental` | Mask-like brute force, can run forever |
| `--users=FILE` | Only attack specific users |
| `--pot=FILE` | Use a specific potfile |

## Rules

`--rules` uses `/etc/john/john.conf`, which has several rule sets in it. You
select one with `--rules=Name`:

```bash
john --wordlist=wl.txt --rules=Jumbo hashes.txt
```

## The `*2john` tools

This is john's real advantage. Each of these extracts a hash from a file format
and writes it in a form john can read.

| Tool | Target |
|---|---|
| `zip2john` | encrypted zip |
| `rar2john` | encrypted rar |
| `7z2john.pl` | encrypted 7z |
| `ssh2john` | SSH private key with a passphrase |
| `pdf2john.pl` | encrypted PDF |
| `office2john.py` | password protected Office documents |
| `keepass2john` | KeePass database |
| `bitlocker2john` | BitLocker volume |
| `gpg2john` | GPG private key |
| `pfx2john.py` | PKCS#12 certificate bundle |

Typical use, cracking a passphrase protected SSH key:

```bash
ssh2john id_rsa > key.hash
john --wordlist=/usr/share/wordlists/rockyou.txt key.hash
john --show key.hash
```

## Linux shadow files

`/etc/shadow` is not readable by a normal user, but if you have root, or a copy,
you can crack the hashes in it. The hashes need the usernames from
`/etc/passwd` alongside them, and `unshadow` joins the two files:

```bash
unshadow /etc/passwd /etc/shadow > combined.txt
john --wordlist=/usr/share/wordlists/rockyou.txt combined.txt
john --show combined.txt
```

john handles md5crypt, sha256crypt and sha512crypt from the `$1$`, `$5$` and
`$6$` prefixes automatically.

## The potfile

john stores what it cracks in `~/.john/john.pot`. This is separate from
hashcat's potfile, so cracking something in one tool does not tell the other.

```bash
john --show hashes.txt
```

## john or hashcat?

| | hashcat | john |
|---|---|---|
| Hardware | GPU, needs OpenCL | CPU, always works |
| Speed on fast hashes | Far faster | Slower |
| File extraction tools | none | the `*2john` family |
| Format detection | you must give `-m` | auto-detects |
| Works in a VM | often needs `pocl` or `--force` | yes |

In practice: use john to get the hash out of a file and identify it, then use
whichever tool your hardware favours to crack it. On a laptop in a VM, john is
usually the one that just works.

## Practise

Exercise 4 in [practice.md](practice.md) is designed to be done in both tools so
you can feel the speed difference on a salted hash.

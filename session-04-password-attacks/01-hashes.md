# Hashes: what they are and how to identify them

[Session index](README.md) | [Next: Exercise 1: identify the type](02-exercise-identify.md)

## What a hash is

A hash function takes any input and produces a fixed length output, called a
digest or a hash. The same input always produces the same output, and you cannot
go backwards from the output to the input.

Four properties matter:

| Property | Meaning |
|---|---|
| One way | You cannot reverse a hash into the original input |
| Deterministic | The same input always gives the same hash |
| Fixed length | MD5 is always 32 hex characters, no matter how long the input is |
| Avalanche | A one character change produces a completely different hash |

That last one is why you cannot guess your way towards an answer. There is no
"close". Either you find the exact input or you have nothing.

## Hashing is not encryption

Encryption is reversible, and it uses a key. Hashing is not reversible and uses
no key. If something is encrypted you can decrypt it with the key. If something
is hashed you have to guess inputs until one of them produces the same hash.

This is why "cracking" a hash is really just guessing. There is no clever trick
that undoes it.

## Why passwords are stored as hashes

A well built application never stores your password. It stores the hash of your
password. When you log in it hashes what you typed and compares.

The upshot for us: if we dump a database, we get hashes, not passwords. The
hashes are still useful, because we can guess.

## Salting, and why salted hashes are harder

Without a salt, two users with the same password have the same hash. That lets
an attacker do two things:

1. Precompute a huge table of common passwords and their hashes, called a
   rainbow table, and look yours up instantly.
2. Crack one hash and immediately know every user who shares that password.

A salt is random data mixed into the password before hashing, and it is stored
alongside the hash. Now the same password gives a different hash for every user,
rainbow tables stop working, and every hash has to be attacked separately.

You can see the salt in the hash. This is an md5crypt hash:

```
$1$BQ/uFdiw$Q3rt8IeuzOM0PwqPxfN/3.
```

`$1$` says which algorithm, `BQ/uFdiw` is the salt, and the rest is the digest.

## Fast hashes and slow hashes

This is the single most important idea for choosing an attack.

| Kind | Examples | Speed | Why |
|---|---|---|---|
| Fast | MD5, SHA1, SHA256, NTLM | Billions per second on a GPU | Built for checksums, not passwords |
| Slow | bcrypt, scrypt, argon2, sha512crypt | Thousands per second | Deliberately expensive, tunable cost factor |

If you are looking at a bcrypt hash, a rockyou wordlist that would finish in
seconds against MD5 can take hours or days. Recognising that early stops you
wasting a night on the wrong attack.

## Where hashes come from on a job

Context often tells you the type before any tool does.

| Source | What you get | hashcat mode |
|---|---|---|
| `/etc/shadow` on Linux | md5crypt, sha256crypt, sha512crypt, yescrypt | 500, 7400, 1800 |
| Windows SAM plus SYSTEM | NTLM | 1000 |
| Windows SAM plus SYSTEM | LM, usually an empty password placeholder | 3000 |
| `NTDS.dit` on a domain controller | NTLM for every domain account | 1000 |
| Responder or similar on the wire | NetNTLMv2 | 5600 |
| Kerberoasting | Kerberos 5 TGS-REP | 13100 |
| AS-REP roasting | Kerberos 5 AS-REP | 18200 |
| Web app database dump | Depends on the app: MD5, bcrypt, Django, PHP `password_hash` | varies |
| WPA handshake | WPA-PBKDF2-PMKID plus EAPOL | 22000 |

## The identification table

Keep this next to you. Mode numbers are the ones you type into hashcat.

| Type | Looks like | hashcat `-m` | john `--format` |
|---|---|---|---|
| MD5 | 32 hex | 0 | raw-md5 |
| SHA1 | 40 hex | 100 | raw-sha1 |
| SHA256 | 64 hex | 1400 | raw-sha256 |
| SHA512 | 128 hex | 1700 | raw-sha512 |
| NTLM | 32 hex | 1000 | nt |
| LM | 32 hex, often uppercase, often `aad3b...` | 3000 | lm |
| NetNTLMv2 | `user::domain:challenge:response:blob` | 5600 | netntlmv2 |
| md5crypt | starts `$1$` | 500 | md5crypt |
| sha256crypt | starts `$5$` | 7400 | sha256crypt |
| sha512crypt | starts `$6$` | 1800 | sha512crypt |
| bcrypt | starts `$2a$`, `$2b$` or `$2y$` | 3200 | bcrypt |
| Kerberoast TGS-REP | starts `$krb5tgs$` | 13100 | krb5tgs |
| AS-REP | starts `$krb5asrep$` | 18200 | krb5asrep |
| MySQL 4.1+ | 40 hex, often with a leading `*` | 300 | mysql-sha1 |
| MSSQL 2012+ | starts `0x0200` | 1731 | mssql12 |
| WPA-PBKDF2 | 64 hex plus a handshake file | 22000 | wpapsk |

## Identify by prefix

If the hash starts with a `$`, the prefix usually names the algorithm outright.

| Prefix | Algorithm |
|---|---|
| `$1$` | md5crypt |
| `$5$` | sha256crypt |
| `$6$` | sha512crypt |
| `$2a$`, `$2b$`, `$2y$` | bcrypt |
| `$argon2id$` | argon2 |
| `$pbkdf2-sha256$` | PBKDF2 |
| `$krb5tgs$` | Kerberoast |
| `$krb5asrep$` | AS-REP |
| `{SSHA}` | LDAP salted SHA1 |
| `sha1$` or `md5$` | Django |
| `*` followed by 40 hex | MySQL 4.1+ |

## Identify by shape, and the trap that catches everyone

Length and character set narrow it down, but they do not settle it.

**A 32 hex character string is MD5, NTLM, MD4 or LM. You cannot tell which by
looking.** They are all 16 bytes rendered as hex.

This matters because a wrong guess wastes your time. If you assume MD5 when it
is really NTLM you will point hashcat at mode 0 and crack nothing, and you will
probably conclude the password is not in your wordlist rather than that your
mode is wrong.

The fix is context. Where did the hash come from?

- Out of `/etc/shadow` on Linux? It will have a `$` prefix, so it is a crypt
  format, not a bare 32 hex string.
- Out of a Windows SAM or from `secretsdump`? It is NTLM. Windows stores NTLM,
  not MD5.
- Out of a web app database? Could genuinely be either. Look at the app source
  or the column name.
- LM hashes are usually shown uppercase, and the LM hash of an empty password is
  always `aad3b435b51404eeaad3b435b51404ee`. If you see that value, that account
  has no LM hash, which is normal on modern Windows.

If you are stuck between two types and both are cheap, just try both. MD5 and
NTLM are both fast, so running two attacks costs you very little.

## Identify with tools

**hashid** is the quickest first pass. It prints every type that could match.

```bash
hashid 8846f7eaee8fb117ad06bdd830b7586c
```

Useful flags:

```bash
# print the matching hashcat mode
hashid -m 8846f7eaee8fb117ad06bdd830b7586c

# print the matching john format
hashid -j 8846f7eaee8fb117ad06bdd830b7586c
```

hashid is a helper, not an oracle. For a bare 32 hex string it will list MD5,
NTLM, MD4 and more, in no useful order. Deciding between them is your job.

**hashcat itself** can show you what a format looks like:

```bash
# browse every example, search for a keyword
hashcat --example-hashes | less

# show the example for one specific mode
hashcat -m 1000 --example-hashes
```

**hashes.com** is a web service for identification and lookup. It is useful for
two things: confirming a type you are unsure about, and checking whether a hash
is already in a public database.

```
https://hashes.com/en/tools/hash_identifier
https://hashes.com/en/decrypt/hash
```

Two warnings. First, submitting a hash to a public site publishes it. On a real
engagement that can leak client data and may breach your scope, so get written
permission first. Second, a lookup hit means somebody else already cracked it,
which tells you nothing about your own wordlists or rules, so do not let it
replace learning the tools.

**john** can list what it supports:

```bash
john --list=formats | tr ',' '\n' | head -50
```

## The workflow

1. Look at the hash. Prefix, length, character set. Write down the candidates.
2. Use the context. Where did it come from? That usually settles it.
3. Confirm with `hashid -m`.
4. Pick the cheapest attack that could work. Dictionary first, then rules, then
   mask.
5. Crack. If it fails, question your mode and your wordlist before you question
   the password.

## Now do it

Go to [Exercise 1](02-exercise-identify.md). It is pure identification, with no
cracking. Do that before you read any further.

[Session index](README.md) | [Next: Exercise 1: identify the type](02-exercise-identify.md)

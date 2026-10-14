# Solutions

[Previous: Exercise 5: close the loop](09-exercise-close-the-loop.md) | [Session index](README.md)

How these hashes were made: every hash in `practice/` was generated from the
plaintexts listed on this page. The answers are known by construction, so nobody
had to crack anything to write this file. That also means if a hash here does
not crack for you, the problem is your mode, your wordlist or your rule, not the
hash being unbreakable.

Try the exercises first, starting at [Exercise 1](02-exercise-identify.md).

## Exercise 1: identify, do not crack

| Line | Algorithm | hashcat `-m` | How you know |
|---|---|---|---|
| 1 | MD5 | 0 | 32 hex. Ambiguous by shape alone |
| 2 | SHA1 | 100 | 40 hex |
| 3 | SHA256 | 1400 | 64 hex |
| 4 | NTLM | 1000 | 32 hex, the same shape as line 1. Context decides |
| 5 | LM placeholder | 3000 | a well known constant, see below |
| 6 | md5crypt | 500 | `$1$` prefix |
| 7 | sha512crypt | 1800 | `$6$` prefix |
| 8 | bcrypt | 3200 | `$2b$` prefix, `12` is the cost factor |

The hints:

- **Lines 1 and 4 are the pair.** Both are 32 hex characters and there is no way
  to tell MD5 from NTLM by looking at the string. In a real job the context
  settles it: a hash pulled from a Windows SAM or from `secretsdump` is NTLM,
  because Windows does not store MD5 password hashes. A hash out of a web
  application database has to be identified from the application, not the string.
- **Line 5 is the constant.** `aad3b435b51404eeaad3b435b51404ee` is the LM hash
  of an empty password. Seeing it tells you the account has no LM hash stored,
  which is the normal state on modern Windows. There is no password to recover.
- **Lines 6, 7 and 8 name themselves** with the `$1$`, `$6$` and `$2b$` prefixes.

## Exercise 2: dictionary attack, level1.txt

| Line | Type | Mode | Password |
|---|---|---|---|
| 1 | MD5 | 0 | `sunshine` |
| 2 | SHA1 | 100 | `football` |
| 3 | SHA256 | 1400 | `iloveyou` |
| 4 | NTLM | 1000 | `letmein` |

```bash
hashcat -m 0    -a 0 level1.txt wordlist.txt
hashcat -m 100  -a 0 level1.txt wordlist.txt
hashcat -m 1400 -a 0 level1.txt wordlist.txt
hashcat -m 1000 -a 0 level1.txt wordlist.txt
```

Each run loads only the lines that parse for the mode you gave it, warns about
the lines it skipped, and cracks the one that matches. That is why four modes
against one mixed file works, and also why running `-m 0` alone leaves three
hashes uncracked rather than erroring.

## Exercise 3: rules, level2.txt

| Line | Type | Mode | Password |
|---|---|---|---|
| 1 | MD5 | 0 | `Summer2026!` |
| 2 | SHA1 | 100 | `Winter2026!` |
| 3 | NTLM | 1000 | `Autumn2026!` |

The wordlist holds `summer2026`, `winter2026` and `autumn2026` in lowercase. The
rule file capitalises the first letter and appends an exclamation mark:

```
c $!
```

`c` is capitalise the first letter, `$!` is append `!`. Applied to `summer2026`
that produces `Summer2026!`.

```bash
hashcat -m 0    -a 0 level2.txt wordlist.txt -r rules/mutate.rule
hashcat -m 100  -a 0 level2.txt wordlist.txt -r rules/mutate.rule
hashcat -m 1000 -a 0 level2.txt wordlist.txt -r rules/mutate.rule
```

Without `-r`, none of these crack. That is the lesson: the password is not a
word, it is a word that has been transformed, and rules are how you cover
transformations without needing a list that already contains the answer.

To append `2026` instead, the rule is `c $2 $0 $2 $6`, or simply add a line
`c $2026` to your own copy of the rule file. One rule per line, and every rule
is tried against every word.

## Exercise 4: salted and slow, level3.txt

| Line | Type | Mode | Salt | Password |
|---|---|---|---|---|
| 1 | md5crypt | 500 | `MAXcT9kh` | `dragon` |
| 2 | sha512crypt | 1800 | `N75s5GVF676hy02g` | `monkey` |
| 3 | bcrypt | 3200 | cost `12` | `princess` |

```bash
# hashcat, one mode at a time
hashcat -m 500  -a 0 level3.txt wordlist.txt
hashcat -m 1800 -a 0 level3.txt wordlist.txt
hashcat -m 3200 -a 0 level3.txt wordlist.txt

# john, formats detected from the prefixes
john --wordlist=wordlist.txt level3.txt
john --show level3.txt
```

Answers to the questions:

- **Speed.** bcrypt at cost 12 is deliberately slow, so it will be the slowest of
  the three in either tool. If you are in a VM, hashcat may not run at all until
  you install a CPU OpenCL runtime, while john will just work.
- **john and the mixed file.** john reads the `$1$`, `$6$` and `$2b$` prefixes
  and picks a format per line, so one file with three types is fine. hashcat
  needs one `-m` per type, so it takes three runs.
- **What bcrypt tells you.** Each guess costs real work by design, and the cost
  factor is tunable. A wordlist that finishes in seconds against MD5 can take
  hours against bcrypt. Against a properly configured application this pushes you
  away from cracking and towards finding the password somewhere else: config
  files, reuse, a leak, or the application itself.

## Exercise 5: close the loop, unknown.txt

| Line | Type | Mode | Result |
|---|---|---|---|
| 1 | MD5 | 0 | `password` |
| 2 | SHA1 | 100 | `password` |
| 3 | SHA256 | 1400 | `password` |
| 4 | NTLM | 1000 | `password` |
| 5 | LM placeholder | 3000 | nothing to crack, see exercise 1 |
| 6 | md5crypt | 500 | `password123` |
| 7 | sha512crypt | 1800 | `password123` |
| 8 | bcrypt | 3200 | `password123` |

Notice that lines 1 to 4 are the same password stored four different ways, which
is exactly why the same word sounds different depending on the application. And
notice that lines 6 to 8 are a different password entirely, so cracking one
group tells you nothing about the other.

## Checking your own answer without cracking

For a fast hash you can confirm a candidate by hashing it once and comparing,
which costs a single hash rather than a cracking run:

```bash
printf '%s' sunshine | openssl dgst -md5
```

For a salted hash you need the salt that is stored in the hash string itself,
which is why you cannot reuse a result across users.

## If a hash does not crack

In order of likelihood:

1. Wrong `-m`. This is the most common cause by far.
2. The plaintext is not in your wordlist and no rule produces it.
3. You are running a salted or slow hash and gave up before it finished.
4. hashcat cannot see a device, which is a hardware problem, not a hash problem.

[Previous: Exercise 5: close the loop](09-exercise-close-the-loop.md) | [Session index](README.md)

# Wordlists and mutation

[Previous: 03-john.md](03-john.md) | [Session index](README.md) | [Next: Exercise 1: identify the type](05-exercise-identify.md)

Most cracks succeed because of the wordlist, not the tool. This page is about
picking and building the right one.

## Where wordlists live on Kali

| Path | What it is |
|---|---|
| `/usr/share/wordlists/rockyou.txt` | 14 million real leaked passwords, the default first try |
| `/usr/share/wordlists/rockyou.txt.gz` | the same file, compressed. `gunzip` it first |
| `/usr/share/seclists/` | the SecLists collection, organised by purpose |
| `/usr/share/seclists/Passwords/Common-Credentials/` | top 10, 100, 1000, 10000, 1000000 lists |
| `/usr/share/seclists/Passwords/Leaked-Databases/` | leaked password sets besides rockyou |
| `/usr/share/seclists/Usernames/` | username lists, for spraying |
| `/usr/share/seclists/Discovery/Web-Content/` | directory and file names, for web fuzzing |

If rockyou is still compressed:

```bash
sudo gunzip /usr/share/wordlists/rockyou.txt.gz
```

## Strategy, in the order you should try it

### Step 1: Start broad

Try the obvious lists first. They are cheap and they catch the majority of weak
passwords.

```bash
hashcat -m 1000 -a 0 h.txt /usr/share/wordlists/rockyou.txt
```

### Step 2: Go targeted

If you know anything about the target, use it. Company name, product names,
season, year, location, sporting teams. Build a short list of words that matter
to this organisation and mutate it hard.

```bash
# a handful of words that matter here
cat > company.txt <<'EOF'
acmecorp
acme
invoice
london
EOF
```

### Step 3: Go personal, if you have OSINT

People build passwords from their own life. Names of partners, children, pets,
birthdays, and the year. `CUPP` generates these from a short interview:

```bash
cupp -i
```

It asks for names, dates and keywords, then writes a personalised list. This is
also the answer to "why would a targeted list beat rockyou".

### Step 4: Mutate

A base list plus rules beats a bigger flat list almost every time. This is where
`Summer2026!` comes from when your list only has `summer2026`.

```bash
hashcat -m 1000 -a 0 h.txt company.txt -r /usr/share/hashcat/rules/best64.rule
```

### Step 5: Keyboard walks

`qwerty`, `1qaz2wsx` and similar are in the leaked lists, but long walks are not.
`kwprocessor` generates them from a keyboard layout:

```bash
kwp -s 1 basechars/full.base keymaps/en-us.keymap routes/2-to-16-max-3-direction-changes.route
```

### Step 6: Masks, last

Only when you know something concrete, like a fixed length or a known prefix.
See the mask section in [the hashcat page](02-hashcat.md).

## Generating a mutated list as a file

Sometimes you want the mutated list itself, for spraying or for another tool.
`--stdout` writes candidates to standard output instead of attacking:

```bash
# mutate a base list with best64 and save the result
hashcat -a 0 -m 0 /dev/null company.txt -r /usr/share/hashcat/rules/best64.rule --stdout > mutated.txt
```

Note the `/dev/null` in place of a hash file. With `--stdout` there is nothing
to attack, you just want the generated candidates.

## Building a wordlist from a website

`cewl` crawls a site and collects the words on it. Useful for a company site
where the product names are all over the marketing pages:

```bash
cewl https://example.com -d 2 -m 6 -w site-words.txt
```

`-d 2` is crawl depth, `-m 6` is minimum word length.

## Combining list plus rules

You can also point `-a 1` at two lists, which pairs every word in the first
with every word in the second:

```bash
hashcat -m 0 -a 1 h.txt first-names.txt years.txt
```

This gets large quickly. Two lists of 10000 words is 100 million candidates.

## A note on spraying versus brute forcing

Worth knowing now because Session 4 uses Hydra, and because the two are often
confused.

| | Brute force | Password spraying |
|---|---|---|
| What you try | many passwords against one account | one password against many accounts |
| Lockout risk | high, you will lock the account | low, one attempt per account |
| Good for | a single account you must get into | a domain or a large user base |
| Tool | hashcat, Hydra with a list | Hydra, NetExec, Kerbrute |

On a real engagement spraying is usually the smarter first move, because one
wrong guess per account does not trip a lockout counter. Brute force suits
isolated lab services where no lockout policy exists. Always check the lockout
policy before you spray anything.

## Keep it honest

A wordlist is a guess about human behaviour. If your crack fails, the useful
question is not "is the password strong" but "what would this person have typed".
That is the whole skill.

[Previous: 03-john.md](03-john.md) | [Session index](README.md) | [Next: Exercise 1: identify the type](05-exercise-identify.md)

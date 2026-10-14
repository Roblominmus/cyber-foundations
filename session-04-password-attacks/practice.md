# Practice

Five exercises. Do them in order. Answers are in [solutions.md](solutions.md),
so try first and only look when you are stuck.

Everything runs from the `practice` folder:

```bash
cd practice
ls
```

You should see:

```
unknown.txt  level1.txt  level2.txt  level3.txt  wordlist.txt  rules/
```

## Exercise 1: identify, do not crack

Eight hashes in `unknown.txt`. This exercise is only about saying what each one
is. Do not run hashcat yet.

```bash
cat -n unknown.txt
```

For each line, write down:

- the algorithm
- the hashcat mode you would use
- how you know, or why you are unsure

Then check yourself with hashid:

```bash
cat unknown.txt | while read -r h; do echo "--- $h"; hashid -m "$h"; done
```

Hints, only if you need them:

- Two of these are the same shape as each other but are different algorithms.
  Which two, and how would you tell them apart in a real job?
- One of them is a well known constant that means "this account has no such
  hash". Which one, and what is it telling you?
- Three of them carry their algorithm in the string itself. What gives them away?

## Exercise 2: dictionary attack

`level1.txt` has four hashes of four different types. The shipped
`wordlist.txt` contains all four passwords.

Run each mode against the file. hashcat loads only the lines that parse for the
mode you gave it, so the other lines are ignored, which is why one file can hold
mixed types:

```bash
hashcat -m 0    -a 0 level1.txt wordlist.txt
hashcat -m 100  -a 0 level1.txt wordlist.txt
hashcat -m 1400 -a 0 level1.txt wordlist.txt
hashcat -m 1000 -a 0 level1.txt wordlist.txt
```

Then confirm everything fell:

```bash
hashcat -m 0    level1.txt --show
hashcat -m 100  level1.txt --show
hashcat -m 1400 level1.txt --show
hashcat -m 1000 level1.txt --show
```

Questions:

- Which mode cracked which line?
- What happens if you run `-m 0` and the answer is an NTLM hash? Try it and
  describe the output.

## Exercise 3: you need rules

`level2.txt` holds three hashes that the plain wordlist will not crack. The
passwords are a season, a year and a symbol.

The rule file `rules/mutate.rule` turns `summer2026` into `Summer2026!`.

Look at the rule file first, then run:

```bash
cat rules/mutate.rule

hashcat -m 0    -a 0 level2.txt wordlist.txt -r rules/mutate.rule
hashcat -m 100  -a 0 level2.txt wordlist.txt -r rules/mutate.rule
hashcat -m 1000 -a 0 level2.txt wordlist.txt -r rules/mutate.rule
```

Questions:

- Prove that exercise 2 fails on this file. Run it without `-r` and show that
  nothing cracks.
- Write your own extra rule that appends `2026` and try it.
- Why is mutating a small list better here than downloading a bigger list?

## Exercise 4: salted and slow

`level3.txt` holds three hashes of three different passwords, one md5crypt, one
sha512crypt and one bcrypt. All three are salted, so the same password would
produce a different hash every time.

With hashcat:

```bash
hashcat -m 500  -a 0 level3.txt wordlist.txt
hashcat -m 1800 -a 0 level3.txt wordlist.txt
hashcat -m 3200 -a 0 level3.txt wordlist.txt
```

With john, letting it detect the formats:

```bash
john --wordlist=wordlist.txt level3.txt
john --show level3.txt
```

Questions:

- Time both tools. Which is faster on bcrypt, and by how much?
- The file has three different hash types in it. How did john handle that?
- bcrypt at cost 12 is intentionally slow. What does that tell you about
  attacking a real application that uses bcrypt properly?

## Exercise 5: close the loop

Go back to `unknown.txt`. You identified all eight in exercise 1. Now crack
every one of them.

Two notes before you start:

- Four of the hashes are the same password in four different algorithms. When
  you crack one, you have a strong hint for the others.
- Line 5 is a constant. You will not "crack" it, you should explain it instead.

```bash
hashcat -m 0    -a 0 unknown.txt wordlist.txt
hashcat -m 100  -a 0 unknown.txt wordlist.txt
hashcat -m 1400 -a 0 unknown.txt wordlist.txt
hashcat -m 1000 -a 0 unknown.txt wordlist.txt
hashcat -m 500  -a 0 unknown.txt wordlist.txt
hashcat -m 1800 -a 0 unknown.txt wordlist.txt
hashcat -m 3200 -a 0 unknown.txt wordlist.txt
```

Then check what you have:

```bash
hashcat -m 0 unknown.txt --show
```

## When you are done

Go to the room in the track and do it again there. The point of this page was to
make the first time you see these tools not be under time pressure.

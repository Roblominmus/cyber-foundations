# Exercise 2: dictionary attack

[Previous: Exercise 1](05-exercise-identify.md) | [Session index](README.md) | [Next: Exercise 3](07-exercise-rules.md)

**Goal:** crack four hashes of four different types using one wordlist.

The lesson here is that a single file can hold mixed types, and that your `-m`
decides which lines get attacked.

## The hashes

In order: one MD5, one SHA1, one SHA256, one NTLM. Four different passwords.

```
0571749e2ac330a7455809c6b0e7af90
2d27b62c597ec858f6e7b54e7e58525e6a95e6d8
e4ad93ca07acb8d908a3aa41e920ea4f4ef4f26e7f86cf8291c5db289780a5ae
becedb42ec3c5c7f965255338be4453c
```

## The wordlist

Fifteen words. This writes both files for you:

```bash
cat > level1.txt <<'EOF'
0571749e2ac330a7455809c6b0e7af90
2d27b62c597ec858f6e7b54e7e58525e6a95e6d8
e4ad93ca07acb8d908a3aa41e920ea4f4ef4f26e7f86cf8291c5db289780a5ae
becedb42ec3c5c7f965255338be4453c
EOF

cat > wordlist.txt <<'EOF'
password
password123
sunshine
football
iloveyou
letmein
dragon
monkey
princess
summer
winter
autumn
summer2026
winter2026
autumn2026
EOF
```

## Attack it

Run each mode against the same file. hashcat loads only the lines that parse for
the mode you gave it, so the other three are skipped and it does not error:

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

## Questions

- Which mode cracked which line?
- What does the output look like when you run `-m 0` and the answer is an NTLM
  hash? Try it and describe what happened.
- Why does one file with four types work here, when normally you would separate
  them?

## When you are done

Compare with exercise 2 in [10-solutions.md](10-solutions.md), then move on to
[Exercise 3](07-exercise-rules.md).

[Previous: Exercise 1](05-exercise-identify.md) | [Session index](README.md) | [Next: Exercise 3](07-exercise-rules.md)

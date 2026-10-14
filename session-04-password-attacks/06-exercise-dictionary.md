# Exercise 2: dictionary attack

[Previous: Exercise 1](05-exercise-identify.md) | [Session index](README.md) | [Next: Exercise 3](07-exercise-rules.md)

**Goal:** crack four hashes of four different types using one wordlist.

The lesson here is that a single file can hold mixed types, and that your `-m`
decides which lines get attacked.

## The hashes

Four hashes, four different types, four different passwords. Work out what each
one is before you run anything.

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

hashcat loads only the lines that parse for the mode you gave it, so one file can
hold several types at once and each run attacks only its own. That is why you do
not have to split the file up.

Work out what each hash is, then run the matching mode, once per type:

```bash
hashcat -m <mode> -a 0 level1.txt wordlist.txt
```

When you think you have all four, list what cracked, using those same modes:

```bash
hashcat -m <mode> level1.txt --show
```

## Questions

- Which mode cracked which line?
- What happens when the mode you run does not match any line in the file? Try it
  and describe the output.
- Why does one file with several types work here, when you might expect to have
  to separate them?

## When you are done

Compare with exercise 2 in [10-solutions.md](10-solutions.md), then move on to
[Exercise 3](07-exercise-rules.md).

[Previous: Exercise 1](05-exercise-identify.md) | [Session index](README.md) | [Next: Exercise 3](07-exercise-rules.md)

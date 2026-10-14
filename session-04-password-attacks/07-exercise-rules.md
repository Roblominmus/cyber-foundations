# Exercise 3: rules

[Previous: Exercise 2](06-exercise-dictionary.md) | [Session index](README.md) | [Next: Exercise 4](08-exercise-salted.md)

**Goal:** crack passwords that are not words in your list.

The plain wordlist will not touch these. You have to teach the tool how the words
have been transformed, which is exactly what rules are for.

## The hashes

Three hashes of three different types. Work out what each one is first.

```
e56f3bb5392369b6468e744ab1da078b
fa8ed9594223987c8c506a1232ef4af7788dc831
2b5e0a5a41b0c80bcfe599227684fb76
```

## Set up the files

The wordlist is the same one from exercise 2. The rule file is small, so it is
written out here in full. `c` capitalises the first letter, `$!` appends an
exclamation mark.

```bash
cat > level2.txt <<'EOF'
e56f3bb5392369b6468e744ab1da078b
fa8ed9594223987c8c506a1232ef4af7788dc831
2b5e0a5a41b0c80bcfe599227684fb76
EOF

mkdir -p rules
cat > rules/mutate.rule <<'EOF'
c $!
c $1
c $2026
u $!
EOF
```

## First, prove the plain list fails

Run the plain dictionary attack again on this file, with no rules:

```bash
hashcat -m <mode> -a 0 level2.txt wordlist.txt
```

Nothing cracks. That is the point: the password is not a word, it is a word that
has been transformed. You can either find a bigger list that happens to contain
the transformed version, or you can teach the tool the transformation.

## Now add the rules

```bash
hashcat -m <mode> -a 0 level2.txt wordlist.txt -r rules/mutate.rule
```

Once per type, the same modes you just used.

## Questions

- Which rule in the file cracked these three, and why did the others not?
- Write your own rule line that appends `2026` and try it on this file.
- Why is mutating a fifteen word list a better use of a minute than downloading
  a bigger flat list?
- In exercise 2 the list held the answer directly. What changed about the
  attacker's job here?

## When you are done

Compare with exercise 3 in [10-solutions.md](10-solutions.md), then move on to
[Exercise 4](08-exercise-salted.md).

[Previous: Exercise 2](06-exercise-dictionary.md) | [Session index](README.md) | [Next: Exercise 4](08-exercise-salted.md)

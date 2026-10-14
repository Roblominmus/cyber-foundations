# Exercise 5: close the loop

[Previous: Exercise 4: salted and slow](08-exercise-salted.md) | [Session index](README.md) | [Next: Solutions](10-solutions.md)

**Goal:** go back to the eight hashes from exercise 1 and crack every one of them.

You already know what each one is. Now recover the passwords, which is the whole
workflow: identify, choose the attack, run it, confirm.

## The eight, again

One thing to know before you start: one of these will not crack, no matter what
you do. That is not a failure on your part. Work out what it is, and explain what
it means instead of cracking it.

```
5f4dcc3b5aa765d61d8327deb882cf99
5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8
5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8
8846f7eaee8fb117ad06bdd830b7586c
aad3b435b51404eeaad3b435b51404ee
$1$BQ/uFdiw$Q3rt8IeuzOM0PwqPxfN/3.
$6$xed9MnrsV1OykP0v$yPFTLP22V73m30f7SKBU.2TPqVonr.EPWwFGxF7YN.NKjhg/OROTKFAHGI4e5/iMgRewjXlDZEJeoX5rvgzG1.
$2b$12$kJlKr9L4o7tdNy4blVFzTeIe1YHsJai5M/z00pN9wsU2YTTQSu.vW
```

If you need to rebuild the file:

```bash
cat > unknown.txt <<'EOF'
5f4dcc3b5aa765d61d8327deb882cf99
5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8
5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8
8846f7eaee8fb117ad06bdd830b7586c
aad3b435b51404eeaad3b435b51404ee
$1$BQ/uFdiw$Q3rt8IeuzOM0PwqPxfN/3.
$6$xed9MnrsV1OykP0v$yPFTLP22V73m30f7SKBU.2TPqVonr.EPWwFGxF7YN.NKjhg/OROTKFAHGI4e5/iMgRewjXlDZEJeoX5rvgzG1.
$2b$12$kJlKr9L4o7tdNy4blVFzTeIe1YHsJai5M/z00pN9wsU2YTTQSu.vW
EOF
```

## Crack them

The wordlist is the fifteen word one from exercise 2. Seven modes, one file:

```bash
hashcat -m 0    -a 0 unknown.txt wordlist.txt
hashcat -m 100  -a 0 unknown.txt wordlist.txt
hashcat -m 1400 -a 0 unknown.txt wordlist.txt
hashcat -m 1000 -a 0 unknown.txt wordlist.txt
hashcat -m 500  -a 0 unknown.txt wordlist.txt
hashcat -m 1800 -a 0 unknown.txt wordlist.txt
hashcat -m 3200 -a 0 unknown.txt wordlist.txt
```

Note that `-m 3000` is not in that list. Decide whether it should be, and why.

Then see everything you have:

```bash
hashcat -m 0 unknown.txt --show
```

## The question that matters

Write one paragraph answering this, in your own words:

> In your own words: why can the same password produce completely different
> hashes, and why does cracking one hash not automatically give you the others?

If you can answer that, you understand salting, and you are ready to do this on
the room rather than on practice data.

## When you are done

Check everything against [Solutions](10-solutions.md). Then go and do the
room in the track, where the hashes are real and the pressure is higher.

[Previous: Exercise 4: salted and slow](08-exercise-salted.md) | [Session index](README.md) | [Next: Solutions](10-solutions.md)

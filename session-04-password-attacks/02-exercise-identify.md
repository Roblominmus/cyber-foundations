# Exercise 1: identify the type

[Previous: Hashes, and how to identify them](01-hashes.md) | [Session index](README.md) | [Next: hashcat](03-hashcat.md)

**Goal:** look at a hash and say what it is. Do not crack anything yet.

This is the step people skip, and it is the step that decides whether the rest of
your work is wasted. Get the type wrong and you can crack for an hour and
conclude the password is strong, when really you pointed the tool at the wrong
algorithm.

## The hashes

Eight hashes. Do not use hashcat on them yet.

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

If you want them as a file, this writes them, whether or not you cloned the repo:

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

## What to write down

For each of the eight lines:

1. The algorithm.
2. The hashcat mode you would use.
3. How you know, or why you are unsure.

Use a page per line if that helps. The writing down is the exercise, not the
tool output.

## Hints, only if you are stuck

- Two of these lines are the same shape as each other but are different
  algorithms. Which two, and how would you tell them apart on a real job?
- One line is a well known constant that means a specific thing about the
  account. Which one, and what is it telling you?
- Three lines carry their algorithm in the string itself. What gives them away?

## When you are done

Check your answers against Exercise 1 in [Solutions](10-solutions.md), then move on to
[hashcat](03-hashcat.md), which is how every other exercise here gets cracked.

[Previous: Hashes, and how to identify them](01-hashes.md) | [Session index](README.md) | [Next: hashcat](03-hashcat.md)

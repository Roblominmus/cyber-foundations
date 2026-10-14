# Exercise 4: salted and slow

[Previous: Exercise 3](07-exercise-rules.md) | [Session index](README.md) | [Next: Exercise 5](09-exercise-close-the-loop.md)

**Goal:** crack three salted hashes, in both tools, and feel the difference.

These are salted, so the same password hashes differently for every user, and one
of them is deliberately slow to compute. This is where you find out why the
choice of tool matters.

## The hashes

One md5crypt, one sha512crypt, one bcrypt. Three different passwords.

```
$1$MAXcT9kh$pOv.Ys1coTKkgR7jy7Tc31
$6$N75s5GVF676hy02g$1MCxkKmjS1Xr/fhYcPp/6tE9en8xyO1Hwj3Z75jJGIS2stHdn6tsqoJDXYH5Ui5HIJhDFNcGHr2YLZqD4FoZX1
$2b$12$K4l.Mdv/MthSAB39OADl5.pbwxFd1HXqr2a269TY1rXPanPugiBDy
```

Write the file if you have not already got the wordlist from exercise 2:

```bash
cat > level3.txt <<'EOF'
$1$MAXcT9kh$pOv.Ys1coTKkgR7jy7Tc31
$6$N75s5GVF676hy02g$1MCxkKmjS1Xr/fhYcPp/6tE9en8xyO1Hwj3Z75jJGIS2stHdn6tsqoJDXYH5Ui5HIJhDFNcGHr2YLZqD4FoZX1
$2b$12$K4l.Mdv/MthSAB39OADl5.pbwxFd1HXqr2a269TY1rXPanPugiBDy
EOF
```

## With hashcat

One mode at a time, because these are three separate algorithms:

```bash
hashcat -m 500  -a 0 level3.txt wordlist.txt
hashcat -m 1800 -a 0 level3.txt wordlist.txt
hashcat -m 3200 -a 0 level3.txt wordlist.txt
```

If hashcat will not start, that is the virtual machine problem from
[02-hashcat.md](02-hashcat.md). Skip to john and come back to it.

## With john

john reads the `$1$`, `$6$` and `$2b$` prefixes and picks a format per line, so
one file with three types is fine for it:

```bash
john --wordlist=wordlist.txt level3.txt
john --show level3.txt
```

## Questions

- Time both tools on the bcrypt line. Which is faster, and by how much?
- The file holds three different types. How did john handle that without being
  told, and what does hashcat need instead?
- bcrypt here is at cost 12. What does that cost factor do, and what does it
  imply for attacking a real application that uses bcrypt properly?
- What is the salt in the first hash, and why does it stop you reusing a crack
  from another user who has the same password?

## When you are done

Compare with exercise 4 in [10-solutions.md](10-solutions.md), then move on to
[Exercise 5](09-exercise-close-the-loop.md).

[Previous: Exercise 3](07-exercise-rules.md) | [Session index](README.md) | [Next: Exercise 5](09-exercise-close-the-loop.md)

# hashcat

[Previous: Exercise 1: identify the type](02-exercise-identify.md) | [Session index](README.md) | [Next: Exercise 2: dictionary attack](04-exercise-dictionary.md)

hashcat is a password recovery tool. It hashes candidate passwords and compares
them to the target hash. It is built to run on a GPU, which is what makes it
thousands of times faster than a CPU tool against fast hashes.

## The shape of every command

```bash
hashcat -a <attack mode> -m <hash type> <hashfile> [wordlist or mask or rules]
```

- `-m` is the hash type. Get this wrong and you crack nothing.
- `-a` is how you want to generate candidates. Defaults to 0 if you leave it out.
- Everything after the hashfile depends on the attack mode you chose.

## Attack modes: `-a`

| Mode | Name | What it does | Example |
|---|---|---|---|
| 0 | Straight | Tries every word in a wordlist | `hashcat -m 0 -a 0 h.txt wl.txt` |
| 1 | Combination | Pairs every word in list one with every word in list two | `hashcat -m 0 -a 1 h.txt wl1.txt wl2.txt` |
| 3 | Brute force and mask | Generates passwords matching a pattern | `hashcat -m 0 -a 3 h.txt '?u?l?l?l?d?d'` |
| 6 | Hybrid wordlist plus mask | Appends a mask to every word | `hashcat -m 0 -a 6 h.txt wl.txt ?d?d` |
| 7 | Hybrid mask plus wordlist | Prepends a mask to every word | `hashcat -m 0 -a 7 h.txt ?d?d wl.txt` |

## Mask characters for `-a 3`, `-a 6` and `-a 7`

| Symbol | Means |
|---|---|
| `?l` | lowercase letter |
| `?u` | uppercase letter |
| `?d` | digit |
| `?s` | special character |
| `?a` | all of the above |
| `?b` | every byte |

You can define your own sets and refer to them with `?1` to `?4`:

```bash
# two characters from the set abc, then a digit
hashcat -m 0 -a 3 h.txt -1 'abc' '?1?1?d'
```

Masks are powerful but they explode fast. `?a?a?a?a?a?a` is 95 to the power of
six, which is about 735 billion candidates. Only reach for a mask when you know
something about the password format, like a known length or a known prefix.

## Rules: `-r`

Rules mutate every word in your wordlist. This is usually a better use of your
time than a mask, because it keeps you anchored to real passwords.

```bash
hashcat -m 0 -a 0 h.txt wl.txt -r /usr/share/hashcat/rules/best64.rule
```

Common rule files:

| File | Use |
|---|---|
| `best64.rule` | 64 general purpose mutations, fast |
| `rockyou-30000.rule` | Aggressive, generated from real password patterns |
| `dive.rule` | Very large, use when you have time |

Rule syntax, in the order the rule applies:

| Symbol | Means | Example |
|---|---|---|
| `:` | do nothing | `:` |
| `l` | lowercase all | `l` |
| `u` | uppercase all | `u` |
| `c` | capitalise first letter, lowercase rest | `c` |
| `$X` | append character X | `$1`, `$!` |
| `^X` | prepend character X | `^1` |
| `sa` | substitute a for s | `sa` |
| `so0` | replace o with zero | `so0` |

A rule file is one rule per line. This one capitalises the word and appends an
exclamation mark, which turns `summer2026` into `Summer2026!`:

```
c $!
```

That file ships in `practice/rules/mutate.rule`.

## Useful options

| Option | Why |
|---|---|
| `--show` | Print hashes already cracked from the potfile, do not attack |
| `-o out.txt` | Write cracked results to a file |
| `--potfile-path FILE` | Use a specific potfile instead of the default |
| `-b` | Benchmark, useful to see what your machine can do |
| `-w 1` to `-w 4` | Workload profile. 3 is the default, 4 is desktop only |
| `-O` | Optimised kernels, faster, but caps password length at 31 |
| `--username` | Hash file is `user:hash`, ignore the username part |
| `--remove` | Delete cracked hashes from the input file as they fall |
| `--force` | Ignore warnings. Often needed in a VM |

## Seeing what you already cracked

hashcat remembers every crack in a potfile, by default `~/.hashcat/hashcat.potfile`.

```bash
hashcat -m 1000 h.txt --show
```

Always use the same `-m` when you ask for `--show`. The potfile is indexed by
hash type.

## Running hashcat in a VM

This trips up almost everyone. A virtual machine usually has no GPU and no
OpenCL device, so hashcat stops with an error about no devices found.

Options, best first:

1. Do the cracking on the host, not in the VM.
2. Install a CPU OpenCL runtime so hashcat can fall back to the CPU:
   `sudo apt install pocl-opencl-icd`
3. Try `--force`.
4. Use john instead. john is CPU only and always works in a VM, just slower.

If you see `No devices found` or `clGetPlatformIDs`, this is your problem. It is
not a broken hash and it is not a wrong mode.

## Workflow

1. Identify the type. See [Hashes, and how to identify them](01-hashes.md).
2. Check the potfile first. You may have cracked it already:

   ```bash
   hashcat -m 1000 h.txt --show
   ```

3. Start cheap. Dictionary attack with a real wordlist:

   ```bash
   hashcat -m 1000 -a 0 h.txt /usr/share/wordlists/rockyou.txt
   ```

4. Add rules if the dictionary alone fails:

   ```bash
   hashcat -m 1000 -a 0 h.txt /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
   ```

5. Only then consider a mask, and only if you have a reason to.

6. If nothing works, your `-m` is more likely wrong than the password being
   uncrackable. Go back to step 1.

## Practise

Exercises 2 and 3 are hashcat work. Start at [Exercise 2](04-exercise-dictionary.md).

[Previous: Exercise 1: identify the type](02-exercise-identify.md) | [Session index](README.md) | [Next: Exercise 2: dictionary attack](04-exercise-dictionary.md)

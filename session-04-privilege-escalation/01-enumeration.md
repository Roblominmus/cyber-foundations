# 01: Enumeration

[Session index](README.md) | [Next: Techniques](02-techniques.md)

## The rule

You do not find the escalation by guessing. You find it by enumerating until
something looks wrong, and then checking whether that wrong thing is exploitable.

Most people fail at Windows privesc not because they do not know the techniques,
but because they run one automated tool, read a wall of output, and give up. Do
the manual enumeration first, understand the machine, then run the automated tool
and see whether it agrees with you.

## Who am I

```cmd
whoami
whoami /priv
whoami /groups
whoami /all
```

`whoami /priv` is the single most important command here. It lists the token
privileges you hold. Some of them are effectively administrator, even on a low
privileged account. Look for:

- `SeImpersonatePrivilege` or `SeAssignPrimaryTokenPrivilege`: the Potato family of
  attacks, very often a straight path to SYSTEM on a service account.
- `SeBackupPrivilege` or `SeRestorePrivilege`: read any file, including the SAM
  database, by bypassing file permissions.
- `SeDebugPrivilege`: read other processes, including LSASS, which holds creds.
- `SeTakeOwnershipPrivilege`: take ownership of any file, then edit it.
- `SeLoadDriverPrivilege`: load a driver, which means kernel code.
- `SeManageVolumePrivilege`: known abuse path for arbitrary file write.

Note that an unelevated administrator shows these as disabled. That is not the same
as absent.

## The system

```cmd
systeminfo
hostname
ver
wmic qfe get HotFixID,InstalledOn
```

`systeminfo` gives the OS version, build, architecture, and the installed hotfixes.
Missing hotfixes are the kernel exploit path. `systeminfo` is slow on old machines;
`wmic qfe` lists the patches on its own.

## Users and groups

```cmd
net user
net user <username>
net localgroup
net localgroup administrators
net accounts
```

You are looking for other accounts worth targeting, accounts that are not
supposed to be there, and the password policy, which tells you whether a service
account might have a weak password.

## Network and shares

```cmd
ipconfig /all
netstat -ano
route print
arp -a
net share
```

`netstat -ano` shows what is listening. A service listening on `127.0.0.1` only is
a service you cannot reach from outside, but you can once you are on the box.

## Services

```cmd
sc query state= all
sc qc <servicename>
wmic service get name,displayname,pathname,startmode,startname
```

For each service note the `pathname`, the account it runs as (`startname`), and
whether you can write to it. `LocalSystem` is the interesting one. An unquoted
path or a writable binary is a privesc.

## Scheduled tasks

```cmd
schtasks /query /fo LIST /v
```

Tasks that run as SYSTEM, and whose binary or script you can write to, are a
privesc. This is a common CTF and real world finding.

## Installed software and patches

```cmd
wmic product get name,version
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s | findstr DisplayName
```

Slow, but it tells you what is installed. An old vulnerable application, or a
service with a known local exploit, is a route up.

## Files worth hunting

```cmd
# config files
dir /s /b *config* *.xml *.ini *.txt 2>nul

# anything with a password in the name or content
findstr /si /m "password" *.xml *.ini *.txt *.config 2>nul

# powershell history, often contains credentials the admin typed
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt

# saved sessions
dir /a %USERPROFILE%\AppData\Roaming\PuTTY 2>nul
reg query "HKCU\Software\SimonTatham\PuTTY\Sessions" /s 2>nul
cmdkey /list
```

Do not forget the odd places: the root of `C:\`, `C:\inetpub\`, `C:\Temp`,
`C:\Users\Public`, backup folders, and any share you can reach.

## Automated tools, and how to use them properly

Run these after you have formed your own opinion, then compare.

| Tool | What it does |
|---|---|
| `winPEAS` | The big one. Checks a huge list and colour codes findings |
| `Seatbelt` | .NET, security focused, lots of system detail |
| `PowerUp.ps1` | PowerShell, has `Invoke-AllChecks` and ready-made exploits |
| `SharpUp` | The C# port of PowerUp |
| `JAWS` | PowerShell, similar coverage to winPEAS |
| `PrivescCheck` | PowerShell, good writeups in the output |

Transfer one over, run it, and read it in sections rather than scrolling. If it
flags something, go and verify it by hand, because these tools produce false
positives and they will not tell you whether a finding is actually exploitable.

## What to record

For every finding, write down:

- What it is, exactly, with the path or the name.
- The command that showed it.
- Why it might be exploitable.
- Whether you tried it, and what happened.

That last one matters. A clean machine where you tried six things and ruled them
out is a good result, and you cannot show it without notes.

## Practise

You cannot practise enumeration without a box. Go to
[Practice](03-practice.md) now, start the room, and run every command on this
page against it before you read the techniques. Then come back to
[Techniques](02-techniques.md) with real output in front of you.

[Session index](README.md) | [Next: Techniques](02-techniques.md)

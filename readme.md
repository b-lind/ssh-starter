# ssh-starter
## An OpenSSH Client wrapper for the Windows Terminal environment

While there are several tutorials on how to setup OpenSSH in the new Windows Terminal App (like this one: [Tutorial: SSH in Windows Terminal on docs.microsoft.com](https://docs.microsoft.com/en-us/windows/terminal/tutorials/ssh)), they all share one downside: You need individual profiles if you're planning on using the app with different servers and users. The aim of this Powershell-based script is to offer a simple mechanism to use the SSH client with multiple servers and users.

[![PSScriptAnalyzer](https://github.com/b-lind/ssh-starter/actions/workflows/powershell.yml/badge.svg)](https://github.com/b-lind/ssh-starter/actions/workflows/powershell.yml)

### How-To: Setup in the Windows Terminal App
There are two ways to setup a profile for this tool in the Windows Terminal App. One is based on the *.ps1 file and the other one is based on the *.cmd file. They both share the same code base and essentially work the same, but depending on your use-case outside of the Windows Terminal environment you might prefer one option over the other.

#### ssh-starter.ps1
1. Duplicate the default Windows PowerShell profile
2. Set the Starting directory to the location of the ssh-starter.ps1 file
3. Add ` .\ssh-starter.ps1` to the Command line property
4. *Optional:* Change the name and icon of the profile

The corresponding entry in the settings.json might look like this:
```json
{
    "commandline": "%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe .\\ssh-starter.ps1",
    "guid": "{5033a8c8-6b96-4860-9807-85e36312a81a}",
    "hidden": false,
    "icon": "%USERPROFILE%\\Documents\\Powershell\\ssh-starter\\putty-icon.png",
    "name": "SSH Client",
    "startingDirectory": "%USERPROFILE%\\Documents\\Powershell\\ssh-starter",
}
```

#### ssh-starter.cmd
1. Create a new profile
2. Set the Command line property to your cmd-file
4. *Optional:* Change the name and icon of the profile

The corresponding entry in the settings.json might look like this:
```json
{
    "commandline": "%USERPROFILE%\\Documents\\Powershell\\ssh-starter\\ssh-starter.cmd",
    "guid": "{5033a8c8-6b96-4860-9807-85e36312a81a}",
    "hidden": false,
    "icon": "%USERPROFILE%\\Documents\\Powershell\\ssh-starter\\putty-icon.png",
    "name": "SSH Client",
}
```

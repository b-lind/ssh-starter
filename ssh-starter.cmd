@echo off
@echo off

mode 240,9999

pushd %~dp0

powershell -Command "$Code=Get-Content ($ScriptFullname='%~f0');[scriptblock]::Create('Invoke-Command -ScriptBlock {function PS1CMD(){'+($Code[($Code.IndexOf('#_Start_of_Powershell_')+1)..$Code.Count] -join [Environment]::NewLine)+'};PS1CMD %*}').Invoke()"

popd

exit /b %errorlevel%

rem ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#_Start_of_Powershell_

param($A, $B, $C)

$ErrorActionPreference = 'SilentlyContinue'

$ScriptRoot      = [System.IO.Path]::GetPathRoot(                $ScriptFullname)
$ScriptPath      = [System.IO.Path]::GetDirectoryName(           $ScriptFullname)
$ScriptFilename  = [System.IO.Path]::GetFileName(                $ScriptFullname)
$ScriptName      = [System.IO.Path]::GetFileNameWithoutExtension($ScriptFullname)
$ScriptExtension = [System.IO.Path]::GetExtension(               $ScriptFullname)

#///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function Show-Choice 
{
    param (
        $Choices,
        $TextFormat,
        $Question,
        $CustomOption,
        $CustomQuestion
    )

    $c = 1

    Write-Host $Question

    $Choices | ForEach-Object -Process { Write-Host "[$c]: $(Invoke-Expression $TextFormat)"; $c++ }

    Write-Host "[x]: $CustomOption"

    $id = Read-Host "[-]"

    Write-Host ""

    if($id -gt $c)
    {
        @{Result=$(Read-Host $CustomQuestion); ResultId=-1}
    }
    else
    {
        @{Result=$($Choices[$id - 1]); ResultId=$id - 1;}
    }
}

function Show-Prompt
{
    param (
        $Question
    )

    $yn = Read-Host "$Question (y/n)"

    if($yn -eq "y")
    {
        $true
    }
    elseif($yn -eq "n")
    {
        $false
    }
    else
    {
        Show-Prompt -Question $Question
    }
}

Clear-Host

$hostnames = Get-Content .\ssh-starter-config.json | ConvertFrom-Json

$host_choice = Show-Choice -Choices $hostnames -TextFormat '"$($_.Name)`t`t$($_.Host)"' -Question "Choose a Host:" -CustomOption "Other Hostname" -CustomQuestion "Hostname"

Write-Host " "

if($host_choice.ResultId -eq -1)
{
    $hostname = $host_choice.Result
    $user = Read-Host "Username"

    if(Show-Prompt "`nSave this hostname and username for later?")
    {
        $name = Read-Host "Name for the new Host"
        
        $hostnames += [pscustomobject]@{ Name=$name; Host=$hostname; Users=@($user) }
    }
}
else
{
    $hostname = $host_choice.Result.Host

    $user_choice = Show-Choice -Choices $host_choice.Result.Users -TextFormat '"$_"' -Question "Choose a User:" -CustomOption "Other User" -CustomQuestion "Username"
        
    $user = $user_choice.Result

    if(($user_choice.ResultId -eq -1) -and $(Show-Prompt "`nSave this username for later?"))
    {
        $hostnames[$host_choice.ResultId].Users += $user
    }
}

Write-Host "`nConnecting to $user@$hostname...`n"

$hostnames | ConvertTo-Json | Out-File ssh-starter-config.json

Start-Process -FilePath "ssh.exe" -ArgumentList "$user@$hostname" -Wait -NoNewWindow

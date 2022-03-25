[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '', Scope='Function', Target='Show-Choice', Justification='Known issue with scriptblocks (s. Issue #1472)')]
param(
    [string] $ConfigFile = ".\ssh-starter-config.json"
)
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

    if($Choices.Length -eq 0)
    {
        return @{Result=$(Read-Host $CustomQuestion); ResultId=-1}
    }

    Write-Host "$Question (Default: [1]):"

    $Choices | ForEach-Object -Process { Write-Host "[$c]: $(Invoke-Command $TextFormat)"; $c++ }

    Write-Host "[x]: $CustomOption"

    $id = Read-Host "[-]"

    Write-Host ""

    if(($id -match "^[\d]+$") -and (1..$Choices.Length).Contains([int]$id))
    {
        @{Result=$($Choices[$id - 1]); ResultId=$id - 1;}
    }
    elseif($id -eq "")
    {
        @{Result=$($Choices[0]); ResultId=0;}
    }
    else
    {
        @{Result=$(Read-Host $CustomQuestion); ResultId=-1}

        Write-Host " "
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

if(Test-Path $ConfigFile)
{
    $hostnames = Get-Content $ConfigFile | ConvertFrom-Json
}
else
{
    $hostnames = @()
}

$host_choice = Show-Choice -Choices $hostnames -TextFormat { "$($_.Name)`t`t$($_.Host)" } -Question "Choose a Host" -CustomOption "Other Hostname" -CustomQuestion "Hostname"

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

    $user_choice = Show-Choice -Choices $host_choice.Result.Users -TextFormat { "$_" } -Question "Choose a User" -CustomOption "Other User" -CustomQuestion "Username"

    $user = $user_choice.Result

    if(($user_choice.ResultId -eq -1) -and $(Show-Prompt "`nSave this username for later?"))
    {
        $hostnames[$host_choice.ResultId].Users += $user
    }
}

Write-Information -InformationAction Continue "`nConnecting to $user@$hostname...`n"

$hostnames | ConvertTo-Json | Out-File $ConfigFile

Start-Process -FilePath "ssh.exe" -ArgumentList "$user@$hostname" -Wait -NoNewWindow
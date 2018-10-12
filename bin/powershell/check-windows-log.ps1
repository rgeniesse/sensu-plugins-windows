<#
.SYNOPSIS 
    Returns all occurances of pattern in log file 
.DESCRIPTION
    Checks log file for pattern and returns line(s) containing pattern
.Notes
    FileName    : check-windows-log.ps1
    Author      : Patrice White - patrice.white@ge.com
.LINK 
    https://github.com/sensu-plugins/sensu-plugins-windows
.PARAMETER LogName 
    Required. The name of the log file.
    Example -LogName example.log
.PARAMETER Pattern
    Required. The pattern you want to search for.
    Example -LogName example.log -Pattern error
.EXAMPLE
    powershell.exe -file check-windows-log.ps1 -LogPath example.log -Pattern error
#>

# TODO: Find a windows place to make state file.
#       Make state files based on log path to ensure uniqueness
#       Incoperate new logic into current logic
#       Add better log output
#       Test on windows
#       Make script more readable (white space)
#       Update top comments.
#       Functionize???

#       QA:
#       1 Run script with only log file existing, no state file.
#       2 Run script with no log file existihg, but state file exists.
#       3 Run script with log file not existing, no state file.
#       4 Run script with with log file existing and state file.
#       4a Run again to ensure expected behaivor.
#       5 Run script against large log file (1gb+)
#       5a Possible other perfromance issues.
#       6 Ensure array index won't look at the same log line twice.

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True)]
  [string]$LogPath,
  [Parameter(Mandatory=$True)]
  [string]$Pattern,
  [Parameter(Mandatory=$False)]
  [string]$StateFile = "/tmp/test.txt"
)


if(Test-Path $LogPath){
    $ThisLogLength = Get-Content $LogPath | Measure-Object –Line

    If(Test-Path $StateFile){
    $previsouLength = Get-Content $StateFile
    $myContent = Get-Content $LogPath | Select-Object -Index ($previsouLength..$ThisLogLength.Lines)
    $ThisLogLength.Lines | Out-File $StateFile
    }else{ #Create state file if not found
    New-Item $StateFile -ItemType file | Out-Null
    $ThisLogLength.Lines | Out-File $StateFile
    $myContent = Get-Content $LogPath
    }
}else{
    Write-Host "File at $LogPath was not found"
    EXIT 1 #Should this be a 1 or 2? Unknown?
}

#Search for pattern inside of File
$ThisLog = Select-String -InputObject $myContent -Pattern $Pattern -AllMatch

#Show matched lines if they exist
If($ThisLog -eq $null ){
  "CheckLog OK: The pattern doesn't exist in $LogPath"
  EXIT 0
}else{
  $ThisLog
  "CheckLog CRITICAL"
  EXIT 2
}

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

# [CmdletBinding()]
# Param(
#   [Parameter(Mandatory=$True)]
#   [string]$LogPath,
#   [Parameter(Mandatory=$True)]
#   [string]$Pattern
# )


# TODO: Find a windows place to make state file.
#       Make state files based on log path to ensure uniqueness
#       Get rid of hard coded stuff
#       Incoperate new loggic into current logic
#       Ensure old pattern searching logic looks at new way to get log file entries
#       Test on windows

#       QA:
#       1 Run script with only log file existing, no state file.
#       2 Run script with no log file existihg, but state file exists.
#       3 Run script with log file not existing, no state file.
#       4 Run script with with log file existing and state file.
#       4a Run again to ensure expected behaivor.
#       5 Run script against large log file (1gb+)
#       5a Possible other perfromance issues.


$ThisLogLength = Get-Content test.log | Measure-Object –Line

If(Test-Path /tmp/test.txt){
  $previsouLength = Get-Content /tmp/test.txt
  $myContent = Get-Content test.log | Select-Object -Index ($previsouLength..$ThisLogLength.Lines)
  $myContent
  $ThisLogLength.Lines | Out-File /tmp/test.txt
}else{ #Create state file if not found
  New-Item /tmp/test.txt -ItemType file | Out-Null
  $ThisLogLength.Lines | Out-File /tmp/test.txt
  $myContent = Get-Content test.log
  $myContent
}

#Search for pattern inside of File
# $ThisLog = Select-String -Path $LogPath -Pattern $Pattern -AllMatch

#Show matched lines if they exist
# If($ThisLog -eq $null ){
#   "CheckLog OK: The pattern doesn't exist in log"
#   EXIT 0
# }else{
#   $ThisLog
#   "CheckLog CRITICAL"
#   EXIT 2
# }

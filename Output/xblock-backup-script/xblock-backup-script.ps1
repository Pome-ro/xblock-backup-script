
<#PSScriptInfo

.VERSION 1.0.0

.GUID b80d3f1f-0bec-4398-ae42-09751acacbef

.AUTHOR Mansfield Public Schools

.COMPANYNAME Mansfield Public Schools

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
    See Changelog.md


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 This script backs up the XBlock Data sheets using RClone 

#> 
Param()


function Verb-Noun {
    [CmdletBinding()]
    param (
    
    )
    
    begin {
        
    }
    
    process {
    }
    
    end {
        
    }
}
#----------------------------------------------------------[Configuration]----------------------------------------------------

$Config = Import-PowershellDataFile -Path "$PSScriptRoot\XBS.Config.psd1"
Import-Module -Name $Config.RequiredModules
$ErrorActionPreference = 'Continue'

#----------------------------------------------------------[Logging]----------------------------------------------------------

$LM = New-LogManager
$scriptName = $(Get-ChildItem $PSCommandPath).BaseName
$sLogPath = Join-Path -Path $Config.logRoot -ChildPath $ScriptName

if (!$(Test-Path $sLogPath)) {
    New-Log -LogManager $LM -Message "Making Folder $sLogPath"
    New-Item -Path $sLogPath -ItemType Directory
}

$sLogName = "$(get-date -Format MM-dd-yy).log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

New-FileLogger -Path $sLogFile -logLevel Info -LogManager $LM
New-FileLogger -Path $sLogFile -logLevel Error -LogManager $LM
New-ConsoleLogger -logLevel Info -LogManager $LM
New-Log -LogManager $LM -Message "Logging Started" -LogLevel Info
# ---------------- Start Script ---------------- #
if(!$ENV:Path -like "*rclone*"){
    $ENV:Path += ";$config.rclonepath"
}
$date = Get-Date
$formatDate = Get-Date -Format yyyy-MM-dd
$month = (get-culture).datetimeformat.getmonthname($date.Month)
$year = $date.year

$files = @(
    [PSCustomObject]@{
        grade = "grade 5"
        gfile = "XBlock (Grade 5) (Responses).xlsx"
    },
    [PSCustomObject]@{
        grade = "grade 6"
        gfile = "XBlock (Grade 6) (Responses).xlsx"
    },
    [PSCustomObject]@{
        grade = "grade 7"
        gfile = "XBlock (Grade 7) (Responses).xlsx"
    },
    [PSCustomObject]@{
        grade = "grade 8"
        gfile = "XBlock (Grade 8) (Responses).xlsx"
    }
)

foreach($file in $files){
    $localdisk = "C:\scripts\xblockbackup\$($file.gfile)"
    $gdrive = "GDSD-XBlockCore:$($file.gfile)"
    rclone -P copyto $gdrive $localdisk -vv 
}

foreach($file in $files){
    $localdisk = "C:\scripts\xblockbackup\$($file.gfile)"
    $gfilename = "$formatdate-$($file.grade).xlsx"
    $gdrive = "GDSD-XBlockCore:Sheet Archive\$year\$month\$($file.grade)\$gfilename"
    rclone -P copyto $localdisk $gdrive --drive-import-formats xlsx -vv 
}




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

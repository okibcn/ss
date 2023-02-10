#   Scoop Super Search v4.0 2023.02.09
#   (C) 2023 Oscar Lopez
#   For more information visit: https://github.com/okibcn/ss"


## Finds texts in local scoop database
function ss {
    $tac = get-date
    $cNormal = "$([char]27)[37m"  # White
    $cMatch = "$([char]27)[33m"  # Yellow
    $cOfficial = "$([char]27)[0;35m"  # Cyan
    $cSMaster = "$([char]27)[36m"  # Purple
    $oHelp = $oName = $oExact = $oLast = $oRaw = $oRegex = $oOfficial = $oPage = $false
    $pattern = foreach ($arg in $args) {
        $arg = [string]$arg
        if (($arg[0] -eq '-') -AND ($arg[2] -eq $null)) {
            switch ($arg[1]) {
                'n' { $oName = $true  ; break }
                'l' { $oLast = $true  ; break }
                'h' { $oHelp = $true  ; break }
                'e' { $oRegex = $true ; break }
                'r' { $oRaw = $true  ; break }
                'o' { $oOfficial = $true  ; break }
                'p' { $oPage = $true  ; break }
                's' { 
                    $oExact = $true
                    $oName = $true 
                }
            }
        }
        else {
            $arg
        }
    }
    if (($oHelp) -OR (!$oRaw)) {
        Write-Host " Scoop Super Search v4.0 2023.02.09
 (C) 2023 Oscar Lopez
 ss -h for help. For more information visit: https://github.com/okibcn/ss"
    }
    if (($oHelp) -OR ($pattern.count -eq 0)) {
        Write-Host "
 Usage: ss [ [ [-n] [ -s|-e ] [-l] [-o] [-r] [-p] ] | -h ] [Search_Patterns]

 ss searches in all the known buckets at a lighning speed. It not only searches 
 in the name field, but also in the desscription. Regex and UTF-8 compatible.
 If you use more than one pattern, ss returns manifests matching all of them.

 Options:

  no opt. searches for all the matches in the name and description fields.
     -n   Searches only in the name field.
     -s   Simple search. searches an exact name match (implies -n).
     -e   Full expanded regex search.
     -l   Search latest versions only.
     -o   Search only in official buckets.
     -p   Shows homepage for each manifest.
     -r   raw, no color and no header. Outputs data as a PowerShell object.
     -h   Shows this help.

 Examples:

     ss scoop search (all the packages with both words in the name or description)
     ss -n nvidia driver (the name contains both 'nvidia' AND 'driver')
     ss -n `"nvidia|radeon`" tool  (contains 'tool' and, 'nvidia' or 'radeon')
     ss -l search scoop (the latest manifests of scoop search utilities)
     ss -n -l -e ss$ ^s (latests versions of apps ending in 'ss' starting with 's')
     ss -l 音乐 (UTF-8 search)
     `$apps = ss -r .*  (stores in `$apps a PSObject with all the Scoop manifests)

     "
        return
    }

    $DBfile = "$($env:TEMP)/AllAppsDB.7z"
    if ((-NOT (test-path $DBfile)) -OR (((Get-Date) - (gci $DBfile).LastWriteTime).Minutes -ge 30)) {
        aria2c --allow-overwrite=true https://github.com/okibcn/ScoopMaster/releases/download/Databases/AllAppsDB.7z -d "$env:TEMP" | Out-Null
    }
    $csv = 7z e -so $DBfile AllAppsDB.csv | select-object -skip 1
    $nManifests = $csv.count
    if ($oLast) {
        $csv = $csv | Select-String -Pattern "okibcn/ScoopMaster" -raw
    }
    if ($oOfficial) {
        $csv = $csv | Select-String -Pattern '"Scoopinstaller/' -raw
    }
    if ($oExact) {
        # Exact name match
        $csv = $csv | Select-String -Pattern "^`"$pattern`"" -raw
        if (!$csv) { return }
        $table = (echo '"Name","Version","Date","Bucket","Description","Homepage"'$csv) | ConvertFrom-Csv
    }
    else {
        # prefilter non regex search
        if (!$oRegex) {
            $pattern | % { $csv = $csv | Select-String -pattern "$_" -raw }
        }
        if (!$csv) { return }
        $table = (echo '"Name","Version","Date","Bucket","Description","Homepage"'$csv) | ConvertFrom-Csv
        if ($oName) {
            # search name field only
            $pattern | % { 
                $pattern_ = $_
                $table = $table | ? { ($($_.Name) -match "$pattern_" ) }
            }
        }
        else {
            # search name and description
            $pattern | % { 
                $pattern_ = $_
                $table = $table | ? { ($($_.Name) -match "$pattern_" ) -OR ($($_.Description) -match "$pattern_") }
            }
        }
    }
    # $table | % {$_.Date = Get-Date $_.Date}
    $table | % { $_.bucket = "http://github.com/$($_.bucket)" }
    if ($oRaw) {
        return ($table | Select-Object Name, Version, Date, Homepage, Bucket, Description) 
    }

    # Colorize if we are not in raw mode
    $pattern | % {
        $pattern_ = $_
        Foreach ($line in $table) {
            $line.Name = $line.Name -replace "($pattern_)", "$cMatch`$1$cNormal"
            if (!$oName) {
                $line.Description = $line.Description -replace "($pattern_)", "$cMatch`$1$cNormal"
            }
        }
    }
    Foreach ($line in $table) {
        $line.Bucket = $line.Bucket -Replace "(^.*/ScoopInstaller/.*)", "$cOfficial`$1$cNormal"
        $line.Bucket = $line.Bucket -Replace "(^.*/okibcn/ScoopMaster)", "$cSMaster`$1$cNormal"
    }
    $tic = get-date

    #PRINT OUTPUT
    if ($oPage) {
        $table | Select-Object Name, Version, Homepage, Bucket, Description |  Format-Table
    }
    else {
        $table | Select-Object Name, Version, Bucket, Description |  Format-Table
    }
    Write-Host "Legend: $cMatch Search Match$cNormal  - $cOfficial Official Bucket$cNormal  - $cSMaster Most recent Manifest$cNormal"
    Write-Host "Found $cMatch$($table.count)$cNormal matches out of $cMatch$nManifests$cNormal online manifests in $cMatch$([int]($tic-$tac).Milliseconds)$cNormal ms"
}
return ss @args

# New-NISHires.ps1
# Bulk-creates new hires from newhires.csv and licenses them via SG-All-Licensed.

$csvPath = ".\newhires.csv"
$group   = Get-MgGroup -Filter "displayName eq 'SG-All-Licensed'"
if (-not $group) { Write-Host "SG-All-Licensed not found. Stopping." -ForegroundColor Red; return }

$results = @()

foreach ($u in Import-Csv $csvPath) {

    # Skip anyone who already exists
    $existing = Get-MgUser -Filter "userPrincipalName eq '$($u.UPN)'"
    if ($existing) {
        Write-Host "SKIPPED: $($u.UPN) already exists" -ForegroundColor Yellow
        $results += [pscustomobject]@{ UPN = $u.UPN; TempPassword = ""; Status = "Skipped - exists" }
        continue
    }

    # Random temporary password (user must change it at first sign-in)
    $letters = -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object { [char]$_ })
    $temp    = "Nis-$letters-$(Get-Random -Minimum 100 -Maximum 999)!"

    $params = @{
        DisplayName       = $u.DisplayName
        GivenName         = $u.FirstName
        Surname           = $u.LastName
        UserPrincipalName = $u.UPN
        MailNickname      = $u.UPN.Split('@')[0]
        Department        = $u.Department
        JobTitle          = $u.JobTitle
        UsageLocation     = "US"
        AccountEnabled    = $true
        PasswordProfile   = @{ Password = $temp; ForceChangePasswordNextSignIn = $true }
    }

    try {
        $new = New-MgUser @params -ErrorAction Stop
        New-MgGroupMember -GroupId $group.Id -DirectoryObjectId $new.Id -ErrorAction Stop
        Write-Host "CREATED: $($u.UPN)" -ForegroundColor Green
        $results += [pscustomobject]@{ UPN = $u.UPN; TempPassword = $temp; Status = "Created" }
    }
    catch {
        Write-Host "FAILED: $($u.UPN) - $($_.Exception.Message)" -ForegroundColor Red
        $results += [pscustomobject]@{ UPN = $u.UPN; TempPassword = ""; Status = "Failed" }
    }
}

$results | Export-Csv .\onboarding-results.csv -NoTypeInformation
$results | Format-Table
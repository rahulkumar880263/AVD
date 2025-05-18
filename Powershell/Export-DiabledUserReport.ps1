# Creating Variable
$localpath = "C:\TerminatedUserReport"

try{

    # Checking whether TerminatedUserReport Folder is present on the local VM or not
    if (-not (Test-Path -Path $localpath)) {
        New-Item -Path "C:\" -Name "TerminatedUserReport" -ItemType "directory"
        Write-Output "TerminatedUserReport directory has been successfully created"
        Write-Output "Exporting Disabled User Report to the TerminatedUserReport Directory"

        # Exporting Disabled User report from Active Directory
        Get-ADUser -filter {(Enabled -eq $false)} | Select-Object SamAccountName,SID | Export-Csv -Path "C:\TerminatedUserReport\TerminatedUserReport.csv"
        Write-Output "Disabled User Report has been successfully exported"
    
    } else {

        Write-Output "TerminatedUserReport directory is already present"
        Write-Output "Exporting Disabled User Report to the TerminatedUserReport Directory"

        # Exporting Disabled User report from Active Directory
        Get-ADUser -filter {(Enabled -eq $false)} | Select-Object SamAccountName,SID | Export-Csv -Path "C:\TerminatedUserReport\TerminatedUserReport.csv"
        Write-Output "Disabled User Report has been successfully exported"
    }
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}

Get-Date -DisplayHint Date
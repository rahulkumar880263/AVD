# Define your Azure Storage account details
$storageAccountName = "teststoragecloudinfra"
$resourcegroupname = "Test-RG"
$shareName = "fslogix"
$source = "TerminatedUserScript"
$Total_number_of_directories_scanned = 0
$Total_number_of_files_scanned = 0
$Totale_number_of_Profile_Containers_deleted = 0 
$activeSessionsHashSet = @{}
$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
$fileName = "TerminatedUserProfile_$dateTime.txt"
$LogFolder = "UserProfileDeletion"
$LogFolderPath = "C:\$($LogFolder)\$($fileName)"
$csvfile = "TerminatedUserProfile/UserReport.csv"
$localpath = "C:\TerminatedUserProfile\UserReport.csv"
$dataarray = @{}


# Setting Credentials
Connect-AzAccount -Identity

# Create a storage context
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount -EnableFileBackupRequestIntent

try {
    #Registering Script under Event log
    if ([System.Diagnostics.EventLog]::SourceExists($source) -eq $false) {
    [System.Diagnostics.EventLog]::CreateEventSource($source, "Application")
    }

    # Checking and Creating Log File Folder in Azure File Share
    $directoryHashSet = @{}
    $directorylists = Get-AzStorageFile -ShareName $shareName -Context $ctx | Where-Object {$_.GetType().Name -eq "AzureStorageFileDirectory"}
    foreach ($directorylist in $directorylists){
    $directoryHashSet[$directorylist.Name] = $true
    }
    if (-not (Test-Path -Path "C:\$($LogFolder)")) {
        New-Item -Path "C:\" -ItemType "directory" -Name $LogFolder
        Write-Output "LogFile Folder got created locally" | Tee-Object -FilePath $LogFolderPath -Append
    }
    if (-not $directoryHashSet.Contains($LogFolder)) {
        New-AzStorageDirectory -Context $ctx -ShareName $shareName -Path $LogFolder
        Write-Output "LogFile Folder got created in Azure File Share under $($sharename) file share" | Tee-Object -FilePath $LogFolderPath -Append
    }
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage | Tee-Object -FilePath $LogFolderPath -Append
    Write-EventLog -LogName "Application" -Source $source -EventID 3002 -EntryType Error -Message $ErrorMessage -Category 1 -RawData 10,20
}

try {
    if (-not (Test-Path -Path "C:\TerminatedUserProfile")) {
        New-Item -Path "C:\" -Name "TerminatedUserProfile" -ItemType "directory"
        Write-Output "TerminatedUserProfile Directory has been created locally" #| Tee-Object -FilePath $LogFolderPath -Append
    } else {
        Write-Output "TerminatedUserProfile Directory is already present in the local machine" #| Tee-Object -FilePath $LogFolderPath -Append
    }

    Get-AzstorageFileContent -ShareName $shareName -Path $csvfile -Destination $localpath -Context $ctx

    #Importing CSV data to a variable
    $csvdata = Import-Csv -Path $localpath
    $n = 0
    #Loop through each row and assign values to variables
    foreach ($row in $csvdata) {
        $variable1 = $row.UserID
        $variable2 = $row.SID
        $variable3 = $Variable1 + "_" + $variable2
        $dataarray[$variable3] = $true
        $n = $n+1
    }
    Write-Output $dataarray.keys
    Write-Output "Total Number of Terminated User profile present = $($n)"
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage | Tee-Object -FilePath $LogFolderPath -Append
    Write-EventLog -LogName "Application" -Source $source -EventID 3002 -EntryType Error -Message $ErrorMessage -Category 1 -RawData 10,20
}


try {
    #Enumerating directory
    $directories = Get-AzStorageFile -ShareName $shareName -Context $ctx | Where-Object {$_.GetType().Name -eq "AzureStorageFileDirectory"}
    echo $directories
    foreach ($directory in $directories) {
        if($dataarray.Contains($directory.Name)){
            #echo $directory.Name
            #Enumerating files under directory
            $files = Get-AzStorageFile -ShareName $shareName -Path $directory.Name -Context $ctx | Get-AzStorageFile
            foreach ($file in $files){ 
                # Preparing path
                $path = Join-Path -Path $directory.Name -ChildPath $file.Name
                # Delete the file from the Terminated User Profile Container
                Write-Output "Deleting: $($file.Name) file from directory $($directory.name)" | Tee-Object -FilePath $LogFolderPath -Append
                Write-EventLog -LogName "Application" -Source $source -EventID 3000 -EntryType Information -Message "Deleting: $($file.Name) file from directory $($directory.name)" -Category 1 -RawData 10,20
                #Remove-AzStorageFile -ShareName $shareName -Path $path -Context $ctx
                Write-Output "$($file.Name) file has been deleted from the directory $($directory.name)" | Tee-Object -FilePath $LogFolderPath -Append
                Write-EventLog -LogName "Application" -Source $source -EventID 3001 -EntryType Information -Message "$($file.Name) file has been deleted from the directory $($directory.name)" -Category 1 -RawData 10,20
            }

            # Deleting the Terminated User Profile directory from the Azure File Share
            Write-Output "Deleting: $($directory.Name) file from directory $($directory.name)" | Tee-Object -FilePath $LogFolderPath -Append
            Write-EventLog -LogName "Application" -Source $source -EventID 3000 -EntryType Information -Message "Deleting: $($file.Name) file from directory $($directory.name)" -Category 1 -RawData 10,20
            #Remove-AzStorageDirectory -ShareName $shareName -Path $directory.Name -Context $ctx
            Write-Output "$($directory.Name) has been deleted from the FSlogix Azure File Share" | Tee-Object -FilePath $LogFolderPath -Append
            Write-EventLog -LogName "Application" -Source $source -EventID 3001 -EntryType Information -Message "$($directory.Name) has been deleted from the FSlogix Azure File Share" -Category 1 -RawData 10,20
        }
    }
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage | Tee-Object -FilePath $LogFolderPath -Append
    Write-EventLog -LogName "Application" -Source $source -EventID 3002 -EntryType Error -Message $ErrorMessage -Category 1 -RawData 10,20
}

Write-Output "`n`nTotal number of Directories Scanned = $($Total_number_of_directories_scanned)" | Tee-Object -FilePath $LogFolderPath -Append
Write-Output "Total number of Files Scanned = $($Total_number_of_files_scanned)" | Tee-Object -FilePath $LogFolderPath -Append
Write-Output "Total number of Lock Files Deleted = $($Totale_number_of_Lock_files_deleted)" | Tee-Object -FilePath $LogFolderPath -Append
Set-AzStorageFileContent -Context $ctx -ShareName $shareName -Source $LogFolderPath -Path "$($LogFolder)\$($fileName)"
Remove-Item -Path "C:\TerminatedUserProfile" -Recurse
Remove-Item -Path "C:\UserProfileDeletion" -Recurse


# Removing Variables
If ($files) { try { Remove-Variable -Name files }catch {} }
If ($directories) { try { Remove-Variable -Name directories }catch {} }
If ($file) { try { Remove-Variable -Name file }catch {} }
If ($directory) { try { Remove-Variable -Name directory }catch {} }
If ($ctx) { try { Remove-Variable -Name ctx }catch {} }
If ($path) { try { Remove-Variable -Name path }catch {} }
If ($source) { try { Remove-Variable -Name source }catch {} }


# Cleanup
If ($storageAccountName) { try { Remove-Variable -Name storageAccountName }catch {} }
If ($storageAccountKey) { try { Remove-Variable -Name storageAccountKey }catch {} }
If ($shareName) { try { Remove-Variable -Name shareName }catch {} }
If ($resourcegroupname) { try { Remove-Variable -Name resourcegroupname }catch {} }
If ($VMname) { try { Remove-Variable -Name VMname }catch {} }
If ($activeSessionsHashSet) { try { Remove-Variable -Name activeSessionsHashSet }catch {} }
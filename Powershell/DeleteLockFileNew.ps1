# Define your Azure Storage account details
$storageAccountName = "teststoragecloudinfra"
$resourcegroupname = "Test-RG"
$shareName = "fslogix"
$VMname = "RunBookVM"

# Setting Credentials
Connect-AzAccount -Identity

# Create a storage context
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount -EnableFileBackupRequestIntent

try { 
    #Enumerating directory
    $directories = Get-AzStorageFile -ShareName $shareName -Context $ctx

    foreach ($directory in $directories) {
        #Enumerating files under directory
        $files = Get-AzStorageFile -ShareName $shareName -Path $directory.Name -Context $ctx | Get-AzStorageFile

        foreach ($file in $files){ 
            # Preparing path
            $path = Join-Path -Path $directory.Name -ChildPath $file.Name

            if ($path -like "*.lock") {
                # Delete the .lock file
                Write-Output "Deleting: $($file.Name) file from directory $($directory.name)"
                #Remove-AzStorageFile -ShareName $shareName -Path $path -Context $ctx
                Write-Output "$($file.Name) file has been deleted from the directory $($directory.name)"
            }
        }
    }
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}

try {
    Stop-AzVM -Name $VMname -ResourceGroupName $resourcegroupname -Force
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}

# Removing Variables
finally {
        If ($files) { try { Remove-Variable -Name files }catch {} }
        If ($directories) { try { Remove-Variable -Name directories }catch {} }
        If ($file) { try { Remove-Variable -Name file }catch {} }
        If ($directory) { try { Remove-Variable -Name directory }catch {} }
        If ($ctx) { try { Remove-Variable -Name ctx }catch {} }
        If ($path) { try { Remove-Variable -Name path }catch {} }
}

# Cleanup
If ($storageAccountName) { try { Remove-Variable -Name storageAccountName }catch {} }
If ($VMname) { try { Remove-Variable -Name VMname }catch {} }
If ($shareName) { try { Remove-Variable -Name shareName }catch {} }
If ($resourcegroupname) { try { Remove-Variable -Name resourcegroupname }catch {} }
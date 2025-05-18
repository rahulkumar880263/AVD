##############################################################################
##############################   Restrictions   ##############################
##############################################################################
# This feature is currently supported only for premium SSD managed disks.
# Performance tiers of shared disks can't be changed while attached to running VMs.
# To change the performance tier of a shared disk, stop all the VMs it's attached to.
# The P60, P70, and P80 performance tiers can only be used by disks that are larger than 4,096 GiB.
# A disk's performance tier can be downgraded only once every 12 hours.
# The system does not return Performance Tier for disks created before June 2020. You can take advantage of Performance Tier for an older disk by updating it with the baseline Tier.
###############################################################################
###############################################################################
#  ***Note - Changing your performance tier has billing implications.         #
###############################################################################

# Defining Variables
$resourceGroupName= "AVDNew" # Specify Resource Group Name on which this script is going to run for upgrading the Performance Tier of the disk
$performanceTier= "P10" #Specify Performance Tier to which the Disk performance is going to be upgraded to

<# Setting Credentials
#Connect-AzAccount -Identity

try {
    $disks = Get-AzDisk -ResourceGroupName $resourceGroupName
    $tasks = New-Object System.Collections.ArrayList
    foreach ($disk in $disks) {
        $job = Start-Job -Name $disk.Name -ScriptBlock {
            if ($disk.Tier -ne $performanceTier) {
                echo $disk.Tier
                $diskUpdateConfig = New-AzDiskUpdateConfig -Tier $performanceTier
                Write-output "[+] Upgrading $($disk.Name) performance tier from $disk.Tier to $($performanceTier)"
                Update-AzDisk -ResourceGroupName $resourceGroupName -DiskName $disk.Name -DiskUpdate $diskUpdateConfig
                echo "[+] $($disk.Name) performance tier has been upgraded from $disk.Tier to $($performanceTier)"
            } else {
                echo "[+] $($disk.Name) performance tier is already $($performanceTier)"
            }
        } -ArgumentList $disk
        [void]$tasks.Add($job)
    } 
    $tasks | Wait-Job | ForEach-Object { Receive-Job -Job $_ }
    echo $tasks
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}

# Removing Variables
finally {
        If ($resourceGroupName) { try { Remove-Variable -Name resourceGroupName }catch {} }
        If ($performanceTier) { try { Remove-Variable -Name performanceTier }catch {} }
        If ($diskUpdateConfig) { try { Remove-Variable -Name diskUpdateConfig }catch {} }
        If ($disks) { try { Remove-Variable -Name disks }catch {} }
        If ($disk) { try { Remove-Variable -Name disk }catch {} }
}#>

$disks = Get-AzDisk -ResourceGroupName $resourceGroupName
$tasks = New-Object System.Collections.ArrayList
foreach ($disk in $disks) {
    if ($disk.Tier -ne $performanceTier) {
        $job = Start-Job -ScriptBlock {
                param($disk)
                # Write output inside the job
                Write-Output "[+] Upgrading $($disk.Name) performance tier from $($disk.Tier) to $($performanceTier)"
                $diskUpdateConfig = New-AzDiskUpdateConfig -Tier $performanceTier
                Update-AzDisk -ResourceGroupName AVDNew -DiskName $disk.Name -DiskUpdate $diskUpdateConfig
                Write-Output "[+] $($disk.Name) performance tier has been upgraded from $($disk.Tier) to $($performanceTier)"
         } -ArgumentList $disk
         [void]$tasks.Add($job)
     }else {
        echo "[+] $($disk.Name) performance tier is already $($performanceTier)"
     }
}

# Wait for all jobs to complete and retrieve their output
$tasks | Wait-Job | ForEach-Object {
    $jobOutput = Receive-Job -Job $_
    # Write the job output to the console
    $jobOutput | ForEach-Object { Write-Host $_ }
}
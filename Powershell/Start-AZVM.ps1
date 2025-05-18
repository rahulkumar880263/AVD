##################################################################
############        To Start Hybrid Worker VM       ##############
##################################################################
# Variables definition
$resourcegroupname = "Test-RG"
$VMname = "RunbookVM"
$runbookName = "Testing-PSScript"
$AutomationAcct = "testing-automation"

Connect-AzAccount -Identity

try {
    Start-AzVM -Name $VMname -ResourceGroupName $resourcegroupname
    while ((Get-AzVM -ResourceGroupName $resourcegroupname -Name $VMname -Status).Statuses[1].DisplayStatus -ne 'VM Running') {
        Start-Sleep -Seconds 10
    }

    while ((Get-AzVM -ResourceGroupName $resourcegroupname -Name $VMname -Status).VMAgent.Statuses[0].DisplayStatus -ne 'Ready') {
        Start-Sleep -Seconds 10
    }

        
    $job = Start-AzAutomationRunbook -AutomationAccountName $AutomationAcct -Name $runbookName -ResourceGroupName $resourcegroupname

    $doLoop = $true
    While ($doLoop) {
        $job = Get-AzAutomationJob -AutomationAccountName $AutomationAcct -Id $job.JobId -ResourceGroupName $resourcegroupname
        $status = $job.Status
        $doLoop = (($status -ne "Completed") -and ($status -ne "Failed") -and ($status -ne "Suspended") -and ($status -ne "Stopped"))
    }

    try {
    Stop-AzVM -Name "DC50Test-01" -ResourceGroupName "ADDS" -force
    Stop-AzVM -Name $VMname -ResourceGroupName $resourcegroupname -force
    }
    catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
    }

}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}

# Removing Variables
finally {
        If ($VMname) { try { Remove-Variable -Name VMname }catch {} }
        If ($resourcegroupname) { try { Remove-Variable -Name resourcegroupname }catch {} }
}
##################################################################
############        To Stop Hybrid Worker VM       ##############
##################################################################
# Variables definition
$resourcegroupname = "Test-RG"
$VMname = "RunbookVM"
$automationAccountName = "testing-automation" 
$runbookname = "Testing-PSScript"

Connect-AzAccount #-Identity

try {
    # Wait for the Runbook job to complete
    $jobs =  Get-AzAutomationJob -AutomationAccountName $automationAccountName -ResourceGroupName $resourcegroupname -RunbookName $runbookname
    $activejobs = $jobs | where {$_.status -eq 'Running' -or $_.status -eq 'Queued' -or $_.status -eq 'New' -or $_.status -eq 'Activating' -or $_.status -eq 'Resuming'}
    foreach($activejob in $activejobs){
        $activejobId = $activejob.JobId
        echo $activejobId
        while ($activejob.Status -ne 'Completed' -and $activejob.Status -ne 'Failed' -and $activejob.Status -ne 'Stopped') {
            Write-Output "Waiting for 30 Seconds as the Runbook is already in Running State"
            Start-Sleep -Seconds 30
            $activejob = Get-AzAutomationJob -AutomationAccountName $automationAccountName -ResourceGroupName $resourcegroupname -Id $activejobId 
        }
    }
     
    Write-Output "$($runbookname) is completed so initiating Hybrid Worker VM shutdown"
    Stop-AzVM -Name $VMname -ResourceGroupName $resourcegroupname -force
    Stop-AzVM -Name "DC50Test-01" -ResourceGroupName "ADDS" -force

}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
}
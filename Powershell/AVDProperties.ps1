Add-Type -AssemblyName System.Web
Connect-AzAccount -Identity
Connect-MgGraph -Identity

$properties = @()
$TotalUserWithAccess = 0


$Subscriptions = Get-AzSubscription
foreach($Subscription in $Subscriptions){
    Select-AzSubscription -Subscription $Subscription.Name
    $ResourceGroups = Get-AzResourceGroup
    foreach ($ResourceGroup in $ResourceGroups){
        $Hostpools = Get-AzWvdHostPool -ResourceGroupName $ResourceGroup.ResourceGroupName
        if($($Hostpools.HostPoolType) -eq "Pooled"){ 
            foreach ($Hostpool in $Hostpools){
                Write-Output "$($Hostpool.Name)  $($Hostpool.Location)"
                $Sessionhosts = Get-AzWvdSessionHost -HostPoolName $Hostpool.Name -ResourceGroupName $ResourceGroup.ResourceGroupName
                if ($Sessionhosts) {   
                    $sessionhostsname = $sessionHosts.Name.Split('/')[1]
                    $vmsname = $sessionhostsname.Split('.')[0]
                    $VM1 = Get-AzVM -ResourceGroupName $ResourceGroup.ResourceGroupName -VMName $vmsname
                    $vmsize = $VM1.HardwareProfile.VmSize
                    $VMsize1 = Get-AzVMSize -VMName $VM1.Name -ResourceGroupName $VM1.ResourceGroupName | where{$_.Name -eq $vmsize}
                    $VMCPU = $VMsize1.NumberOfCores
                    $VMMem = $VMsize1.MemoryInMB/1024
                    Write-Output "$($vmsize) $($VMCPU) $($VMMem)"
                    $Available = 0
                    $Unavailable = 0
                    $Shutdown = 0
                    $SessionHosts = Get-AzWvdSessionHost -HostPoolName $Hostpool.Name -ResourceGroupName $ResourceGroup.ResourceGroupName
                    foreach ($Sessionhost in $Sessionhosts){
                        if ($Sessionhost.Status -eq "Available"){$Available = $Available + 1}
                        elseif($Sessionhost.Status -eq "Shutdown") {$Shutdown = $Shutdown + 1}
                        else{$Unavailable = $Unavailable + 1 }
                    }
                    #Write-Output "$($Hostpool.FriendlyName): $($Sessionhosts.Count) HostPool Region: $($Hostpool.Location)"
                    $Scalingplan = Get-AzWvdScalingPlan -HostPoolName $Hostpool.Name -ResourceGroupName $ResourceGroup.ResourceGroupName
                    if($Scalingplan.ExclusionTag -eq "ExcludeFromScaling-b"){ $ActiveSide = "a" }else {$ActiveSide = "b"}
                    $ApplicationGroups = Get-AzWvdApplicationGroup -ResourceGroupName $ResourceGroup.ResourceGroupName | Select-Object -Property *
                    if ($ApplicationGroups){
                        foreach ($ApplicationGroup in $ApplicationGroups){
                            $RoleAssignments = Get-AzRoleAssignment -Scope $ApplicationGroup.Id
                            foreach ($RoleAssignment in $RoleAssignments) {
                                if ($RoleAssignment.Scope -eq $ApplicationGroup.Id){
                                    #Write-Output "Group Name: $($ROleAssignment.DisplayName)"
                                    $UserCount = Get-MgGroupMemberCount -GroupId $RoleAssignment.ObjectId -ConsistencyLevel eventual
                                    $UserCapacity = $Hostpool.MaxSessionLimit * $Sessionhosts.Count
                                    $NormalCapaity = ((80*$UserCapacity)/100)
                                    $NormalCapaity = [math]::Round($NormalCapaity,0)
                                    #Write-Output "$($Hostpool.FriendlyName) $($UserCount) $($Sessionhosts.Count) $($Hostpool.Location) $($Hostpool.MaxSessionLimit) $($UserCapacity) $($ActiveSide) $($Available) $($Shutdown) $($Unavailable)"
                                    $TotalUserWithAccess = $TotalUserWithAccess + $UserCount 
                                } 
                            }
                        }
                    }
                    $curremttime = Get-Date ([datetime]::UtcNow) -Format O
                    $properties += [PSCustomObject]@{
                                    "TimeGenerated" = $curremttime
                                    "HostPool_Name" = $Hostpool.FriendlyName
                                    "Location" = $Hostpool.Location
                                    "Total_User_With_Access" = $TotalUserWithAccess
                                    "Total_Host" = $Sessionhosts.Count
                                    "Max_Session_Limit" = $Hostpool.MaxSessionLimit
                                    "Machine_Size" = $vmsize
                                    "CPU" = $VMCPU
                                    "Memory" = $VMMem
                                    "User_Capacity" = $UserCapacity
                                    "Normal_Capacity" = $NormalCapaity
                                    } 
                }
            }
        }
    }
}

$properties | Format-Table -AutoSize
$PSVersionTable
$Tablevalues = $properties | ConvertTo-Json -AsArray
$Tablevalues.GetType()
$Tablevalues




# set and store context
$AzureContext = (Connect-AzAccount -Identity).context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContex

$token = (Get-AzAccessToken -ResourceUrl "https://monitor.azure.com//.default").Token | ConvertTo-SecureString -AsPlainText -Force
Write-Output "Automaation Account Token:" $token

# information needed to send data to the DCR endpoint
$endpoint_uri = "https://new-dcr-ezfs-eastus2.logs.z1.ingest.monitor.azure.com" #Logs ingestion URI for the DCR
$dcrImmutableId = "dcr-0874c6e35c144f90b8bc6b9be88adabd" #the immutableId property of the DCR object
$streamName = "Custom-MyTableRawData1" #name of the stream in the DCR that represents the destination table


# Create the JSON payload
$body = $Tablevalues;
$headers = @{"Content-Type"="application/json"};
$uri = "$endpoint_uri/dataCollectionRules/$dcrImmutableId/streams/$($streamName)?api-version=2023-01-01"

$uploadResponse = Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers -StatusCodeVariable 'responseStatusCode' -ResponseHeadersVariable 'responseHeaders' -Authentication Bearer -Token $token

# Outputting the request results for troubleshooting purposes
$responseStatusCode
$responseHeaders
$uploadResponse

<#
$tenantId = "24cb4674-575d-448e-afdb-6a744f7d303b" #Tenant ID the data collection endpoint resides in
$appId = "cd9e9f63-afd6-4930-b26e-cb6cd06450dc" #Application ID created and granted permissions
$appSecret = Get-AzKeyVaultSecret -VaultName "AzAutomation-keyvault" -Name Test-MicrosoftEntra -AsPlainText #Secret created for the application
Write-Output "$($appSecret)"

$scope= [System.Web.HttpUtility]::UrlEncode("https://monitor.azure.com//.default")   
$body = "client_id=$appId&scope=$scope&client_secret=$appSecret&grant_type=client_credentials";
$headers = @{"Content-Type"="application/x-www-form-urlencoded"};
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

$bearerToken = (Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers).access_token
Write-Output "Bearer Token :" $bearerToken



$workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName "test-rg" -Name "PWLLog"
$workspace
$tokenResponse = Invoke-RestMethod -Method Get -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://monitor.azure.com//.default" -Headers @{Metadata="true"}
$tokenResponse
$accessToken = $tokenResponse.access_token
# Define variables
$workspaceId = "8857d5df-2631-44fe-8213-4754961b9899"
$logType = "CustomLogTable"
$timeStampField = Get-Date -Format "o"

$tenantId = "24cb4674-575d-448e-afdb-6a744f7d303b"
$headers = @{"Content-Type"="application/x-www-form-urlencoded"};
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

$header = @{Metadata="true" };
$uri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://monitor.azure.com//.default"
$bearerToken = (Invoke-RestMethod -Uri $uri -Method "Get" -Headers $header).access_token
$bearerToken #>


$tableParams = @'
{
    "properties": {
        "schema": {
            "name": "Test_CL",
            "columns": [
                {
                    "name": "TimeGenerated",
                    "type": "datetime"
                },
                {
                    "name": "HostPool_Name",
                    "type": "string"
                },
                {
                    "name": "Location",
                    "type": "string"
                },
                {
                    "name": "Total_User_With_Access",
                    "type": "int"
                },
                {
                    "name": "Total_Host",
                    "type": "int"
                },
                {
                    "name": "Max_Session_Limit",
                    "type": "int"
                },
                {
                    "name": "Machine_Size",
                    "type": "string"
                },
                {
                    "name": "CPU",
                    "type": "int"
                },
                {
                    "name": "Memory",
                    "type": "int"
                },
                {
                    "name": "User_Capacity",
                    "type": "int"
                },
                {
                    "name": "Normal_Capacity",
                    "type": "int"
                }
            ]
        }
    }
}
'@

Invoke-AzRestMethod -Path "/subscriptions/72518812-7f95-4ccf-a0e3-27ee9128be36/resourcegroups/test-rg/providers/microsoft.operationalinsights/workspaces/PWLLog/tables/Test_CL?api-version=2022-10-01" -Method PUT -payload $tableParams


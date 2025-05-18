{
    "$schema": "https://schema.management.azure.com/schemas/2019-08-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "dataCollectionRuleName": {
            "type": "String",
            "metadata": {
                "description": "Specifies the name of the Data Collection Rule to create."
            }
        },
        "location": {
            "type": "String",
            "metadata": {
                "description": "Specifies the location in which to create the Data Collection Rule."
            }
        },
        "workspaceResourceId": {
            "type": "String",
            "metadata": {
                "description": "Specifies the Azure resource ID of the Log Analytics workspace to use."
            }
        }
    },
    "resources": [
        {
            "type": "Microsoft.Insights/dataCollectionRules",
            "apiVersion": "2023-03-11",
            "name": "[parameters('dataCollectionRuleName')]",
            "location": "[parameters('location')]",
            "kind": "Direct",
            "properties": {
                "streamDeclarations": {
                    "Custom-MyTableRawData1": {
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
                },
                "destinations": {
                    "logAnalytics": [
                        {
                            "workspaceResourceId": "[parameters('workspaceResourceId')]",
                            "name": "myworkspace1"
                        }
                    ]
                },
                "dataFlows": [
                    {
                        "streams": [
                            "Custom-MyTableRawData1"
                        ],
                        "destinations": [
                            "myworkspace1"
                        ],
                        "transformKql": "source | project TimeGenerated, HostPool_Name, Location, Total_User_With_Access, Total_Host, Max_Session_Limit, Machine_Size, CPU, Memory, User_Capacity, Normal_Capacity",
                        "outputStream": "Custom-Test_CL"
                    }
                ]
            }
        }
    ],
    "outputs": {
        "dataCollectionRuleId": {
            "type": "String",
            "value": "[resourceId('Microsoft.Insights/dataCollectionRules', parameters('dataCollectionRuleName'))]"
        }
    }
}
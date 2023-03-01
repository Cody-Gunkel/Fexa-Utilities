Function Set-FexaStatus
{
    <#
    .SYNOPSIS
        Updates a Status_ID for the ID associated with the Fexa Type.
    
    .DESCRIPTION
        Specifies a Fexa endpoint, along with an ID to update the status for, provided a workflow allows that movement. This function is intended for single ID use.
    
    .PARAMETER Fexa_Type
        Specifies an endpoint to point to. For a full list of supported types at this time see fexa_types.psm1

    .PARAMETER Fexa_ID
        The ID of the object the status is updated for.

    .PARAMETER Updated_Status
        The status ID that is being attempted to move to.
    
    .EXAMPLE
        # Specifies the endpoint Subcontractor_Quotes, and ID 12345, and updating the status to 90
        Set-FexaStatus -Fexa_Type "sub_quote" -Fexa_ID 12345 -Updated_Status 90
    #>
    param
    (
        [Parameter(Mandatory)]
        [String]$Fexa_Type,

        [Parameter(Mandatory)]
        [Int]$Fexa_ID,

        [Parameter(Mandatory)]
        [Int]$Updated_Status
    )

    $Local:Fexa_Type = Test-FexaType -Type $Fexa_Type
    [String]$Local:URI = (Get-Content '.\powershell\env.json' | ConvertFrom-Json).subdomain

    If ($null -eq $Fexa_Type)
    {
        Throw "Invalid Selection: $($Local:Fexa_Type) in Set-FexaStatus"
        Return $null
    }

    Try
    {
        $Local:URI = "https://" + $Local:URI + ".fexa.io/api/ev1/" + $Local:Fexa_Type + "/" + $Fexa_ID + "/update_status/" + $Updated_Status

        $Local:Fexa_Data = Invoke-WebRequest -Uri $Local:URI -Method PUT -WebSession $Global:Fexa_Session
        
        If ($Fexa_Data.StatusCode -eq 200)
        {
            Return $($Fexa_Data.Content | ConvertFrom-Json) 
        }
    }
    Catch
    {
        $Error[0]
        <#
        TODO: need to make an error handler if cannot pull json data
        Need to create error handler
        #>
    }
    Return $Local:Fexa_Data.StatusCode
}

Function Set-FexaBody
{
    <#
    .SYNOPSIS
        Updates the body for the ID associated with the Fexa Type.
    
    .DESCRIPTION
        Specifies a Fexa endpoint, along with payload to update the ID provided. This function is intended for single ID use.
    
    .PARAMETER Fexa_Type
        Specifies an endpoint to point to. For a full list of supported types at this time see fexa_types.psm1

    .PARAMETER Fexa_ID
        The ID of the object the payload is for.

    .PARAMETER Updated_Body
        A JSON payload to update the Fexa_ID.
    
    .EXAMPLE
        # Specifies the endpoint Subcontractor_Quotes, and ID 12345, and updates the currency used to USD
        Set-FexaBody -Fexa_Type "sub_quote" -Fexa_ID 12345 -Updated_Body '{"invoices": {"currency": "USD"}}'
    #>
    param
    (
        [Parameter(Mandatory)]
        [String]$Fexa_Type,

        [Parameter(Mandatory)]
        [Int]$Fexa_ID,

        [Parameter(Mandatory)]
        [String]$Updated_Body
    )

    $Local:Fexa_Type = Test-FexaType -Type $Fexa_Type
    [String]$Local:URI = (Get-Content '.\powershell\env.json' | ConvertFrom-Json).subdomain

    If ($null -eq $Fexa_Type)
    {
        Throw "Invalid Selection: $($Local:Fexa_Type) in Set-FexaStatus"
        Return $null
    }

    Try
    {
        $Updated_Body | ConvertFrom-Json | Out-Null
    }
    Catch
    {
        $Error[0]
        <#
        TODO: need to make an error handler if cannot pull json data
        Need to create error handler
        #>
    }

    Try
    {
        $Local:URI = "https://" + $Local:URI + ".fexa.io/api/ev1/" + $Local:Fexa_Type + "/" + $Fexa_ID

        $Local:Fexa_Data = Invoke-WebRequest -Uri $Local:URI -Method PUT -WebSession $Global:Fexa_Session -Body $Updated_Body
        
        If ($Fexa_Data.StatusCode -eq 200)
        {
            Return $($Fexa_Data.Content | ConvertFrom-Json) 
        }
    }
    Catch
    {
        $Error[0]
        <#
        TODO: need to make an error handler if cannot pull json data
        Need to create error handler
        #>
    }
    Return $Local:Fexa_Data.StatusCode
}

Export-ModuleMember -Function Set-FexaStatus
Export-ModuleMember -Function Set-FexaBody
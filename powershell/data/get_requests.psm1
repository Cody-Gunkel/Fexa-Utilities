Function Get-FexaData
{
    <#
    .SYNOPSIS
        Gets JSON Data related to the ID and Fexa Type specified.
    
    .DESCRIPTION
        Specifies a Fexa endpoint, along with an ID to request JSON data for. This function is intended for single ID use.
    
    .PARAMETER Fexa_Type
        Specifies an endpoint to point to. For a full list of supported types at this time see fexa_types.psm1

    .PARAMETER Fexa_ID
        The ID of the object information is being requested for.
    
    .EXAMPLE
        # Specifies the endpoint Subcontractor_Quotes, and ID 12345, and returns the JSON data received.
        Get-FexaData -Fexa_Type "sub_quote" -Fexa_ID 12345
    #>
    param
    (
        [Parameter(Mandatory)]
        [String]$Fexa_Type,

        [Parameter(Mandatory)]
        [Int]$Fexa_ID
    )

    $Local:Fexa_Type = Test-FexaType -Type $Local:Fexa_Type
    [String]$Local:URI = (Get-Content '.\powershell\env.json' | ConvertFrom-Json).subdomain

    If ($null -eq $Local:Fexa_Type)
    {
        Throw "Invalid Selection: $($Local:Fexa_Type) in Get-Data"
        Return $null
    }

    Try
    {
        $Local:URI = "https://" + $Local:URI + ".fexa.io/api/ev1/" + $Local:Fexa_Type + "/" + $FexaID

        $Local:Fexa_Data = Invoke-WebRequest -Uri $Local:URI -Method GET -WebSession $Global:WebSession

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

Function Search-FexaData
{
    <#
    .SYNOPSIS
        Searches a Fexa endpoint using specified filters.
    
    .DESCRIPTION
        Specifies a Fexa endpoint, using specified filters to return up to 100 results.
    
    .PARAMETER Fexa_Type
        Specifies an endpoint to point to. For a full list of supported types at this time see fexa_types.psm1

    .PARAMETER Filters
        Filters to be applied when searching. This follows a VALUE, OPERATOR, PROPERTY scheme.
    
    .EXAMPLE
        # Specifies the endpoint Subcontractor_Quotes, searching by status id's of 1, 5, 13
        # The filtered array will look like: [{"value": [1, 5, 13], "operator": "in", "states.status_id"}]
        Search-FexaData -Fexa_Type "sub_quote" -Filters @("1, 5, 13", "in", "states.status_id")
    #>
    param
    (
        [Parameter(Mandatory)]
        [String]$Fexa_Type,

        [Parameter(Mandatory)]
        [Array]$Filters
    )

    $Local:Fexa_Type = Test-FexaType -Type $Fexa_Type
    [String]$Local:FormattedFilters = "["
    [String]$Local:URI = (Get-Content '.\powershell\env.json' | ConvertFrom-Json).subdomain
    
    If ($null -eq $Local:Fexa_Type)
    {
        Throw "Invalid Selection: $($Local:Fexa_Type) in Search-FexaData"
        Return $null
    }
    
    If ($Filters.Count % 3 -ne 0)
    {
        Throw "Filter Size Incorrect, Multiple of 3 Needed - Size: $($Filters.Count)"
        Return $null
    }

    For ([Int]$Local:i = 0; $Local:i -lt $Filters.count; $Local:i++)
    {
        Switch ($Local:i % 3)
        {
            
            1 {
                # Specified the Value to look for. If the Value is null, it will not put it in a JSON Array
                If ($Filters[$Local:i] -like "null")
                {
                    $Local:FormattedFilters += "{`"value`":null"
                }
                Else
                {
                    $Local:FormattedFilters += "{`"value`":[$($Filters[$Local:i])]"
                }
            }

            2 {
                # Operator to use. Valid options at this time are ["in", "not in", "between"]
                # Refer to the Fexa API documentation regarding filters
                $Local:FormattedFilters += "`"operator`":`"$($Filters[$Local:i])`""
            }

            0 {
                # Specifies the property to filter by.
                $Local:FormattedFilters += "`"property`":`"$($Filters[$Local:i])`"}"
            }

            default {
                # This should NEVER be reached. This is left here on the off chance something happens.
                Write-Host $Filters
                Write-Host $Filters.Count
                Throw "Default Statement reached with Search-FexaData"
                Read-Host
            }
        }

        If ($Local:i -eq ($Filters.count - 1))
        {
            # Ends the JSON Filter Array
            $Local:FormattedFilters += "]"
        }
        Else
        {
            # If there is more than 1 filter (3 in array), will continue to build the JSON Filter.
            $Local:FormattedFilters += ","
        }
    }

    Try {
        $Local:URI = "https://" + $Local:URI + ".fexa.io/api/ev1/" + $Local:Fexa_Type + "filter=" + $Local:FormattedFilters

        $Local:Fexa_Data = Invoke-WebRequest -Uri $URI -Method GET -WebSession $Global:WebSession

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
Export-ModuleMember -Function Get-FexaData
Export-ModuleMember -Function Search-FexaData
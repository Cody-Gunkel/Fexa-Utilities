Function Test-FexaType
{
    <#
    .SYNOPSIS
        Helper Function - Used to define what endpoint for requests.

    .PARAMETER Type
        Shorthand of the endpoint to be used.

    .EXAMPLE
        #Below specifies the Subcontractor_Quote endpoint to be returned
        Test-FexaType -Type "sub_quote"
    #>
    param
    (
        [Parameter(Mandatory)]
        [String]$Type
    )

    Switch ($Type)
    {
        "workorder"  {Return "workorders"            }
        "assignment" {Return "assignments"           }
        "visit"      {Return "visits"                }
        "sub_quote"  {Return "subcontractor_quotes"  }
        "sub_invoice"{Return "subcontractor_invoices"}
        default      {Return $null                   }
    }    
}

Export-ModuleMember -Function Test-FexaType
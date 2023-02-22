# Simple script to grab all categories set up in Fexa.
# Selected Columns is properties of a categories object, see API documentation for specifics

[String]$Local:UserPath = "C:\Users\" + $ENV:USERNAME + "\Desktop\Fexa_Categories.csv"

[Array]$Local:Selected_Columns = @("id", "category", "description", "active", "parent_id", "custom_field_values")

$Local:Selected_Columns -join "," | Out-File -FilePath $Local:UserPath -Append

[String]$Local:Subdomain = (Get-Content '.\powershell\env.json' | ConvertFrom-Json).subdomain
[Array]$Local:Category_Array = @()


For ([Int]$Local:i = 0; $Local:i -lt 500; $Local:i++)
{
    $Local:URI = "https://" + $Local:Subdomain + ".fexa.io/api/ev1/workorder_categories?start=" + ($Local:i * 100)

    $Local:Fexa_Categories = Invoke-RestMethod -Uri $Local:URI -Method GET -WebSession $Global:Fexa_Session

    For ([Int]$Local:x = 0; $x -lt $Local:Fexa_Categories.categories.Count; $Local:x++)
    {
        ForEach ($Local:User_Property in $Local:Selected_Columns)
        {
            $Local:Category_Array += $Local:Fexa_Categories.categories[$Local:x].$Local:User_Property
        }

        $Local:Category_Array -join "," | Out-File -FilePath $Local:UserPath -Append
        $Local:Category_Array = @()

        If ($Local:Fexa_Categories.categories.Count -ne 100)
        {
            Write-Host "All Categories Grabbed; Breaking"
            Break
        }
    }
}
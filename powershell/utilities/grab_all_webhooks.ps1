# This will grab all webhook events, along with their corresponding type_id
# as indicated in the API, along with what Class Fexa has assigned.
# This will also store the results as a JSON on the Desktop as webhooks.json

[String]$Local:UserPath = "C:\Users\" + $ENV:USERNAME + "\Desktop\fexa_users.csv"
[String]$Local:Subdomain = (Get-Content '.\powershell\env.json' | ConvertFrom-Json).subdomain

For ([Int]$Local:i = 0; $Local:i -lt 10; $Local:i++)
{
    $Local:URI = "https://" + $Local:Subdomain + ".fexa.io/api/ev1/webhook_configurations/webhook_event_types?start=" + ($Local:i * 100)
    $Local:Fexa_Webhooks = Invoke-RestMethod -Uri $Local:URI -Method GET -WebSession $Global:Fexa_Session

    $Local:Fexa_Webhooks | ConvertTo-CSV | Out-File -Path $Local:UserPath -Append

    If ($Local:Fexa_Users.user.Count -ne 100)
    {
        Write-Host "All Endpoints Grabbed; Breaking"
        Break
    }
}
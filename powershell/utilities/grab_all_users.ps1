# Simple script to grab all users you can see in Fexa.
# This is mostly a way to audit who is ACTIVE in Fexa at time of running.
# Selected Columns is properties of a user object, see API documentation for specifics

[String]$Local:UserPath = "C:\Users\" + $ENV:USERNAME + "\Desktop\fexa_users.csv"

[Array]$Local:Selected_Columns = @("id", "email", "active")

$Local:Selected_Columns -join "," | Out-File -FilePath $Local:UserPath -Append

[String]$Local:Subdomain = (Get-Content '.\powershell\env.json' | ConvertFrom-Json).subdomain
[Array]$Local:User_Array = @()


For ([Int]$Local:i = 0; $Local:i -lt 500; $Local:i++)
{
    $Local:URI = "https://" + $Local:Subdomain + ".fexa.io/api/ev1/users?start=" + ($Local:i * 100)

    $Local:Fexa_Users = Invoke-RestMethod -Uri $Local:URI -Method GET -WebSession $Global:Fexa_Session

    For ([Int]$Local:x = 0; $x -lt $Local:Fexa_Users.user.Count; $Local:x++)
    {
        ForEach ($Local:User_Property in $Local:Selected_Columns)
        {
            $Local:User_Array += $Local:Fexa_Users.user[$Local:x].$Local:User_Property
        }

        $Local:User_Array -join "," | Out-File -FilePath $Local:UserPath -Append
        $Local:User_Array = @()

        If ($Local:Fexa_Users.user.Count -ne 100)
        {
            Write-Host "All Users Grabbed; Breaking"
            Break
        }
    }
}
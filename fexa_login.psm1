Function New-FexaLogin
{
    [PSCredential]$Local:Fexa_Login = Get-Credential -Message "Please enter your Fexa Username & Password"
    
    [String]$Local:Subdomain = (Get-Content '.\powershell\env.json' | ConvertFrom-Json).subdomain
    $Local:URI = "https://" + $Local:Subdomain + ".fexa.io/main/index#login"

    [HashTable]$Local:Fexa_Header = @{
        "accept-encoding"="gzip, deflate, br";
        "content-type"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9";
        "accept-language"="en-US,en;q=0.9"
    }

    $Local:Fexa_WebResponse = Invoke-WebRequest -Method GET -Headers $Local:Fexa_Header -Uri $Local:URI -SessionVariable Fexa_Session
    [Array]$Local:SplitResponse = $Local:Fexa_WebResponse.RawContent -Split '\r?\n'
    [String]$Local:CSRF_Token = Get-FexaToken -SplitResponse $Local:SplitResponse -Token "csrf-token"

    $Local:URI = "https://" + $Local:Subdomain + ".fexa.io/users/sign_in.json"

    $Local:Fexa_Header.'content-type' = "application/json"

    $Local:Login_Payload = (Get-Content '.\powershell\templates\login_payload.json' | ConvertFrom-Json)
    $Local:Login_Payload.user.email = $Local:Fexa_Login.Username
    $Local:Login_Payload.user.password = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Local:Fexa_Login.Password)))
    $Local:Login_Payload.authenticity_token = $Local:CSRF_Token
    $Local:Login_Payload = ($Local:Login_Payload | ConvertTo-Json)

    $Local:Fexa_WebResponse = Invoke-WebRequest -Method POST -Headers $Local:Fexa_Header -Uri $Local:URI -WebSession $Fexa_Session -Body $Local:Login_Payload

    $Local:URI = "https://" + $Local:Subdomain + ".fexa.io/main/active_token"
    $Local:Fexa_WebResponse = Invoke-WebRequest -Method GET -Headers $Local:Fexa_Header -Uri $Local:URI -WebSession $Fexa_Session

    [String]$Local:Fexa_Email = $Local:Fexa_Login.Username
    $Global:Fexa_Session = $Fexa_Session
    $Global:Fexa_Headers = @{
        "content-type"="application/json";
        "accept"="application/json";
    }

    $Local:Login_Payload = $null
    $Local:Fexa_Login = $null
    
    Return $Local:Fexa_Email
}

Function Get-FexaToken {
    param(
        [Parameter(Mandatory)]
        [Array]$SplitResponse,

        [Parameter(Mandatory)]
        [String]$Token
    )

    $TokenValue = ($SplitResponse | Select-String -Pattern $Token)[0].Line
    $TokenValue = ($TokenValue -Split '"')[3]
    Return $TokenValue
}
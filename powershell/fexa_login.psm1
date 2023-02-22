Function New-FexaLogin
{
    <#
    .SYNOPSIS
        Logs into and obtains an Authentication Token to Fexa

    .DESCRIPTION
        Uses a set of credentials to log into Fexa and obtain an Authentication Token.
    
    .EXAMPLE
        New-FexaLogin
    #>

    [PSCredential]$Local:Fexa_Login = Get-Credential -Message "Please enter your Fexa Username & Password"
    
    [String]$Local:Subdomain = (Get-Content '.\powershell\env.json' | ConvertFrom-Json).subdomain
    $Local:URI = "https://" + $Local:Subdomain + ".fexa.io/main/index#login"

    [HashTable]$Local:Fexa_Header = @{
        "accept-encoding"="gzip, deflate, br";
        "content-type"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9";
        "accept-language"="en-US,en;q=0.9"
    }

    # Grabs the subdomain login page and splits the HTML into an array to grab the csrf-token
    $Local:Fexa_WebResponse = Invoke-WebRequest -Method GET -Headers $Local:Fexa_Header -Uri $Local:URI -SessionVariable Fexa_Session
    [Array]$Local:SplitResponse = $Local:Fexa_WebResponse.RawContent -Split '\r?\n'
    [String]$Local:CSRF_Token = Get-FexaToken -SplitResponse $Local:SplitResponse -Token "csrf-token"

    # Specifies the URI to the sign in to authenticate
    # Then loads the login JSON and sets the data
    # Posts the data to Fexa to obtain the first part of the Authentication
    $Local:URI = "https://" + $Local:Subdomain + ".fexa.io/users/sign_in.json"
    $Local:Fexa_Header.'content-type' = "application/json"
    $Local:Login_Payload = (Get-Content '.\powershell\templates\login_payload.json' | ConvertFrom-Json)
    $Local:Login_Payload.user.email = $Local:Fexa_Login.Username
    $Local:Login_Payload.user.password = ([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Local:Fexa_Login.Password)))
    $Local:Login_Payload.authenticity_token = $Local:CSRF_Token
    $Local:Login_Payload = ($Local:Login_Payload | ConvertTo-Json)

    # After POSTing to Fexa, gets the full Authentication and stores it to $Local:Fexa_Session
    $Local:Fexa_WebResponse = Invoke-WebRequest -Method POST -Headers $Local:Fexa_Header -Uri $Local:URI -WebSession $Fexa_Session -Body $Local:Login_Payload
    $Local:URI = "https://" + $Local:Subdomain + ".fexa.io/main/active_token"
    $Local:Fexa_WebResponse = Invoke-WebRequest -Method GET -Headers $Local:Fexa_Header -Uri $Local:URI -WebSession $Fexa_Session

    # Sets the Fexa Email to what was used to log in. This will be used in future updates for mass updates.
    # Also Nulls the Login_Payload and Fexa_Login due to sensitive data
    # Sets the Fexa_Headers to allow JSON to be sent/received
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

Function Get-FexaToken
{
    <#
    .SYNOPSIS
        Helper Function - Used to grab token from site.

    .DESCRIPTION
        Helper Function - Used to grab token from site.
    
    .PARAMETER SplitResponse
        The HTML Content once it's been split.
    
    .PARAMETER Token
        Token value to look for.
    
    .EXAMPLE
        # Used Abovem will split and find the specific login token needed to authenticate
        Get-FexaToken -SplitResponse $Local:SplitResponse -Token "csrf-token"
    #>
    param
    (
        [Parameter(Mandatory)]
        [Array]$SplitResponse,

        [Parameter(Mandatory)]
        [String]$Token
    )

    $TokenValue = ($SplitResponse | Select-String -Pattern $Token)[0].Line
    $TokenValue = ($TokenValue -Split '"')[3]
    Return $TokenValue
}
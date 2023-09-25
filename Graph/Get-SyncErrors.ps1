#Skript als Admin ausführen!!!!

#Funktion zum Auslesen aller Einträge über den @odata.nextLink
function Get-GraphResourses {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)] [string]$uri
    )
    
    Try {
        # .Input
        $run = 0
        $content = (Invoke-WebRequest -Headers $AuthHeader -Uri $uri -Verbose -UseBasicParsing).Content | ConvertFrom-Json
        $response = [System.Collections.ArrayList]($content.value)
        Write-verbose -message "Get Resources: $($content.value.count)"
        do {
            $run ++
            if ($content.'@odata.nextLink') {
                $content = (Invoke-WebRequest -Headers $AuthHeader -Uri ($content.'@odata.nextLink') -Verbose -UseBasicParsing).Content | ConvertFrom-Json
                $response += $content.value
                Write-verbose -message "Get Resources: $($content.value.count)"
            }
        } until ( -not($content.'@odata.nextLink'))
        Write-Verbose "Total Resources: $($response.count)"
        return $response
    }

    Catch {
        Throw "$($MyInvocation.MyCommand.Name) : Failed to get all Graph Resources. ErrosMessage: $_"
    }
}

$TenantName = "<TenantName>.onmicrosoft.com"  
$AppId = "<App-ID>"  
$Certificate = Get-ChildItem Cert:\LocalMachine\My\<Thumbprint>
$Scope = "https://graph.microsoft.com/.default" # Example: "https://graph.microsoft.com/.default"  
  
# Create base64 hash of certificate  
$CertificateBase64Hash = [System.Convert]::ToBase64String($Certificate.GetCertHash())  
  
# Create JWT timestamp for expiration  
$StartDate = (Get-Date "1970-01-01T00:00:00Z" ).ToUniversalTime()  
$JWTExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End (Get-Date).ToUniversalTime().AddMinutes(2)).TotalSeconds  
$JWTExpiration = [math]::Round($JWTExpirationTimeSpan,0)  
  
# Create JWT validity start timestamp  
$NotBeforeExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End ((Get-Date).ToUniversalTime())).TotalSeconds  
$NotBefore = [math]::Round($NotBeforeExpirationTimeSpan,0)  
  
# Create JWT header  
$JWTHeader = @{  
    alg = "RS256"  
    typ = "JWT"  
    # Use the CertificateBase64Hash and replace/strip to match web encoding of base64  
    x5t = $CertificateBase64Hash -replace '\+','-' -replace '/','_' -replace '='  
}  
  
# Create JWT payload  
$JWTPayLoad = @{  
    # What endpoint is allowed to use this JWT  
    aud = "https://login.microsoftonline.com/$TenantName/oauth2/token"  
  
    # Expiration timestamp  
    exp = $JWTExpiration  
  
    # Issuer = your application  
    iss = $AppId  
  
    # JWT ID: random guid  
    jti = [guid]::NewGuid()  
  
    # Not to be used before  
    nbf = $NotBefore  
  
    # JWT Subject  
    sub = $AppId  
}  
  
# Convert header and payload to base64  
$JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json))  
$EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte)  
  
$JWTPayLoadToByte =  [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json))  
$EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte)  
  
# Join header and Payload with "." to create a valid (unsigned) JWT  
$JWT = $EncodedHeader + "." + $EncodedPayload  
  
# Get the private key object of your certificate  
$PrivateKey = ([System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($Certificate))  
  
# Define RSA signature and hashing algorithm  
$RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1  
$HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256  
  
  
# Create a signature of the JWT  
$Signature = [Convert]::ToBase64String(  
    $PrivateKey.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT),$HashAlgorithm,$RSAPadding)  
) -replace '\+','-' -replace '/','_' -replace '='  
  
# Join the signature to the JWT with "."  
$JWT = $JWT + "." + $Signature  
  
# Create a hash with body parameters  
$Body = @{  
    client_id = $AppId  
    client_assertion = $JWT  
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"  
    scope = $Scope  
    grant_type = "client_credentials"  
  
}  
  
$Url = "https://login.microsoftonline.com/$TenantName/oauth2/v2.0/token"  
  
# Use the self-generated JWT as Authorization  
$Header = @{  
    Authorization = "Bearer $JWT"  
}  
  
# Splat the parameters for Invoke-Restmethod for cleaner code  
$PostSplat = @{  
    ContentType = 'application/x-www-form-urlencoded'  
    Method = 'POST'  
    Body = $Body  
    Uri = $Url  
    Headers = $Header  
}  
  
$Request = Invoke-RestMethod @PostSplat  

# View access_token  
#$Request.access_token

################
#Main Skript

#Hole den Access-Token zum anmelden
$token = $Request.access_token

#Baue den Header
$AuthHeader = @{
 
  Authorization= "Bearer $token"
 
 }

#Verbinde zur Graph API und lese die User aus
$Gr = Get-GraphResourses -uri "https://graph.microsoft.com/beta/users?`$select=id,displayName,userPrincipalName,serviceProvisioningErrors"

#Filter only the users with errors
$Err = $Gr | where {$_.serviceProvisioningErrors}
 
#Human-readable output
$Err | select DisplayName, userPrincipalName, @{n="Errors";e={ ([xml]$_.serviceProvisioningErrors.errorDetail).ServiceInstance.ObjectErrors.ErrorRecord.ErrorDescription } } | Out-GridView

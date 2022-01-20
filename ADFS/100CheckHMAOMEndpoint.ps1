#
# Check-HMAOMEndPoint
# Modified 2018/03/20
# Syntax for running this script:
#
# .\Check-HMAOMEndPoint -easHostName <EAS Public Hostname> -SMTPAddress <Users SMTP Address>
#
# Example:
#
# .\Check-HMAOMEndPoint -easHostName mail.contoso.com -SMTPAddress onprem@contoso.com
#
##############################################################################################
#
# This script is not officially supported by Microsoft, use it at your own risk.
# Microsoft has no liability, obligations, warranty, or responsibility regarding
# any result produced by use of this file.
#
##############################################################################################
# The sample scripts are not supported under any Microsoft standard support
# program or service. The sample scripts are provided AS IS without warranty
# of any kind. Microsoft further disclaims all implied warranties including, without
# limitation, any implied warranties of merchantability or of fitness for a particular
# purpose. The entire risk arising out of the use or performance of the sample scripts
# and documentation remains with you. In no event shall Microsoft, its authors, or
# anyone else involved in the creation, production, or delivery of the scripts be liable
# for any damages whatsoever (including, without limitation, damages for loss of business
# profits, business interruption, loss of business information, or other pecuniary loss)
# arising out of the use of or inability to use the sample scripts or documentation,
# even if Microsoft has been advised of the possibility of such damages
##############################################################################################

param (
    [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String[]]$easHostName,
    [String[]]$SMTPAddress
)
Function Check-AutoDv2EAS {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$easHostName,
        [String[]]$SMTPAddress
    )

    process {
        try {
            $requestURI = "https://$($easHostName)/autodiscover/autodiscover.json?Email=$($SMTPAddress)&Protocol=activesync"
            $headers = @{
                'Accept'         = 'application/json'
                'Content-Length' = '0'
            }
            $webResponse = Invoke-RestMethod -Uri $requestURI -Headers $headers | ConvertTo-Json
            Write-Host
            Write-Host "We sent an AutoDicover v2 Request to the On-Premises EAS vDir and below is the response" -foregroundcolor Green
            Write-Host "The response should contain the Protocol ActiveSync with a vaild URL" -foregroundcolor Yellow
            Write-Host
            Write-Host $($webResponse)
        }
        catch {
            write-host (Convertto-Json $_.Exception.Response)
            $headers = $_.Exception.Response.Headers
            $cookies = $_.Exception.Response.Cookies
            $headers | % { write-host "$_=$($headers[$_])"}
            $cookies | % { write-host "$_=$($cookies[$_])"}
            Write-Error $_.Exception
        }
    }
}
Function Check-EASBearer {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$easHostName
    )

    process {
        try {
            Write-Host
            Write-Host "We sent an Empty Bearer Request to the On-Premises EAS vDir and below is the response" -ForegroundColor Green
            Write-Host "The response should contain a valid WWW-Authenticate=Bearer. Make sure the authorization_uri is populated" -foregroundcolor Yellow
            Write-Host
            $requestURI = "https://$($easHostName)/Microsoft-Server-ActiveSync"
            $authType = "Bearer "
            $headers = @{
                'Accept'         = 'application/json'
                'Authorization'  = $authType
                'Content-Length' = '0'
            }
            $webResponse = Invoke-RestMethod -Uri $requestURI -Headers $headers | ConvertFrom-Json | ConvertTo-Json

        }
        catch {
            $exception = (ConvertTo-Json $_.Exception.Response)
            $headers = $_.Exception.Response.Headers
            $cookies = $_.Exception.Response.Cookies
            $headers | % { write-host "$_=$($headers[$_])"}
            $cookies | % { write-host "$_=$($cookies[$_])"}
            #Write-Error $_.Exception
        }
    }
}
Function Check-AutoDetect {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$SMTPAddress
    )

    process {
        try {
            $RequestURI = "https://prod-api.acompli.net/autodetect/detect?services=office365,outlook,google,icloud,yahoo&protocols=rest-cloud,rest-outlook,rest-office365,eas,imap,smtp"
            $webResponse = Invoke-WebRequest -Uri $RequestURI -Headers @{'x-email' = $($SMTPAddress)} | ConvertFrom-Json
            Write-Host
            Write-Host "Autodetect has the following services listed for the user" -ForegroundColor Green
            Write-Host "This should have AAD pointing to Microsoft Online and OnPrem to the correct EAS URL" -ForegroundColor Yellow
            $webResponse | Select-Object -expand services | Select-Object service, protocol, hostname, aad, onprem
            Write-Host
            Write-Host "Autodetect has the following protocols listed for the user" -ForegroundColor Green
            $webResponse | Select-Object -expand protocols | Select-Object protocol, hostname, port, encryption
        }
        catch {
            write-host (Convertto-Json $_.Exception.Response)
            $headers = $_.Exception.Response.Headers
            $cookies = $_.Exception.Response.Cookies
            $headers | % { write-host "$_=$($headers[$_])"}
            $cookies | % { write-host "$_=$($cookies[$_])"}
            Write-Error $_.Exception
        }
    }
}

Check-AutoDv2EAS -easHostName $easHostName -SMTPAddress $SMTPAddress
Check-EASBearer -easHostName $easHostName
Check-AutoDetect -SMTPAddress $SMTPAddress

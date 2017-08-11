function Remove-AlertContact {
    <#
    .SYNOPSIS
        Deletes an alert contact on Uptime Robot
    
    .DESCRIPTION
        Implements the deleteAlertContact rest endpoint of the Uptime Robot API v2
    
    .PARAMETER ApiKey
        The account or monitor ApiKey for your Uptime Robot account.
    
    .PARAMETER ID
        The alert contact to remove

    .LINKS
        https://uptimerobot.com/api
    
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ApiKey,

        [Parameter(Mandatory=$true)]
        [int]$ID
    )

    Begin {
        [uri]$uri = "$urBaseUri/deleteAlertContact"

        $body = "api_key=$ApiKey&format=json"

        if ( $ID ) { $body += "&id=$ID" }
    }

    Process {
        $result = Invoke-RestMethod -Method Post -UseBasicParsing -Uri $uri.AbsoluteUri -Body $body -ContentType "application/x-www-form-urlencoded"
    }

    End {
        Write-Output $result
    }
}
function Get-AlertContact {
    <#
    .SYNOPSIS
        Retrieves the alert contacts from Uptime Robot
    
    .DESCRIPTION
        Implements the getAlertContacts endpoint of the Uptime Robot API v2

    .PARAMETER ApiKey
        The account or monitor ApiKey for your Uptime Robot account.
    
    .PARAMETER ID
        One or more alert contact ids to retrieve

    .LINKS
        https://uptimerobot.com/api
    
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ApiKey,

        [int[]]$ID
    )

    Begin {
        [uri]$uri = "$urBaseUri/getAlertContacts"

        $body = "api_key=$ApiKey&format=json"

        if ( $ID ) { $body += "&alert_contacts={0}" -f ( $ID -join "-" ) }
    }

    Process {
        $result = Invoke-RestMethod -Method Post -UseBasicParsing -Uri $uri.AbsoluteUri -Body $body -ContentType "application/x-www-form-urlencoded"
    }

    End {
        Write-Output $result
    }
}
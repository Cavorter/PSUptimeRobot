function New-AlertContact {
    <#
    .SYNOPSIS
        Creates a new alert contact on Uptime Robot
    
    .DESCRIPTION
        Implements the newAlertContact rest endpoint of the Uptime Robot API v2
    
    .PARAMETER ApiKey
        The account ApiKey for your Uptime Robot account. The monitor ApiKey will not work with this function.
    
    .PARAMETER Name
        The name of the new alert contact.

    .PARAMETER Type
        The type for the new alert contact

    .PARAMETER Value
        The destination for the new alert contact. This must match the expected value for the type selected. See the API documentation for more details.

    .LINKS
        https://uptimerobot.com/api
    
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ApiKey,

        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [ValidateSet("SMS","Email","Twitter","Boxcar","WebHook","Pushbullet","Zapier","Pushover","HipChat","Slack")]
        [string]$Type,

        [Parameter(Mandatory=$true)]
        [string]$Value
    )

    Begin {
        [uri]$uri = "$urBaseUri/newAlertContact"

        $body = "api_key=$ApiKey&format=json"

        if ( $Name ) { $body += "&friendly_name={0}" -f $Name }
        if ( $Type ) { $body += "&type={0}" -f ( [UptimeRobotAlertContactType]::"$Type" ).value__ }
        if ( $Value ) { $body += "&value={0}" -f $Value }

        $body | Write-Verbose
    }

    Process {
        $result = Invoke-RestMethod -Method Post -UseBasicParsing -Uri $uri.AbsoluteUri -Body $body -ContentType "application/x-www-form-urlencoded"
    }

    End {
        Write-Output $result
    }
}
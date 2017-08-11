function Get-Monitor {
    <#
    .SYNOPSIS
    Retrieves a list of monitors from Uptime Robot
    
    .DESCRIPTION
    Implements the GetMonitors endpoint of the Uptime Robot V2 API.

    .PARAMETER ApiKey
    The account or monitor ApiKey for your Uptime Robot account.

    .PARAMETER ID
    The ids of one or more monitors to retrieve.

    .PARAMETER Type
    One or more types of monitors to retrieve.

    .PARAMETER Status
    Filter monitor list by one or more status values.

    .PARAMETER Logs
    Retrieves the logs associated with each monitor.

    .PARAMETER ResponseTimes
    Retrieves the response times associated with each monitor.

    .PARAMETER AlertContacts
    Retrieves the alert contacts asssociated with each monitor.

    .EXAMPLE
    Get-URMonitor -ApiKey '12345-12345'

    Gets all configured monitors
    
    .EXAMPLE
    Get-URMonitor -ID 98765,87654 -ApiKey '12345-12345'

    Gets the monitors with ids '98765' and '87654'

    .EXAMPLE
    Get-URMonitor -Type HTTP -ApiKey '12345-12345'

    Gets all monitors with the HTTP type.

    .NOTES
    General notes
    #>
    Param(
        [Parameter(Mandatory=$true)]
        [string]$ApiKey,

        [int[]]$ID,

        [ValidateSet("HTTP","Keyword","Ping","Port")]
        [string[]]$Type,

        [ValidateSet("Paused","NotCheckedYet","Up","SeemsDown","Down")]
        [string[]]$Status,

        [switch]$Logs,

        [switch]$ResponseTimes,

        [switch]$AlertContacts
    )

    Begin {
        [uri]$uri = "$urBaseUri/getMonitors"

        $body = "api_key=$ApiKey&format=json"

        if ( $ID ) { $body += "&monitors={0}" -f ( $ID -join "-" ) }
        if ( $Type ) { $body += "&types={0}" -f ( $Type.ForEach({ ([UptimeRobotMonitorType]::"$_").value__ }) -join "-" ) }
        if ( $Status ) { $body += "&statuses={0}" -f ( $Status.ForEach({ ([UptimeRobotMonitorStatus]::"$_").value__ }) -join "-" ) }
        if ( $Logs ) { $body += "&logs={0}" -f [int]$Logs.ToBool() }
        if ( $ResponseTimes ) { $body += "&response_Times={0}" -f [int]$ResponseTimes.ToBool() }
        if ( $AlertContacts ) { $body += "&alert_contacts={0}" -f [int]$AlertContacts.ToBool() }
    }

    Process {
        $result = Invoke-RestMethod -Method Post -UseBasicParsing -Uri $uri.AbsoluteUri -Body $body -ContentType "application/x-www-form-urlencoded"
    }

    End {
        Write-Output $result
    }
}
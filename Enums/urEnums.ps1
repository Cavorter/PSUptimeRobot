# From the Parameters section of https://uptimerobot.com/api

Enum UptimeRobotAlertContactType {
    SMS = 1
    Email = 2
    Twitter = 3
    Boxcar = 4
    WebHook = 5
    Pushbullet = 6
    Zapier = 7
    Pushover = 9
    HipChat = 10
    Slack = 11
}

Enum UptimeRobotAlertContactStatus {
    NotActivated = 0
    Paused = 1
    Active = 2
}

Enum UptimeRobotLogType {
    Down = 1
    Up = 2
    Paused = 99
    Started = 98
}

Enum UptimeRobotMonitorKeywordType {
    Exists = 1
    NotExists = 2
}

Enum UptimeRobotMonitorStatus {
    Paused = 0
    NotCheckedYet = 1
    Up = 2
    SeemsDown = 8
    Down = 9
}

Enum UptimeRobotMonitorSubType {
    HTTP = 1
    HTTPS = 2
    FTP = 3
    SMTP = 4
    POP3 = 5
    IMAP = 6
    Custom = 99
}

Enum UptimeRobotMonitorType {
    HTTP = 1
    Keyword = 2
    Ping = 3
    Port = 4
}

Enum UptimeRobotMWindowType {
    Once = 1
    Daily = 2
    Weekly = 3
    Monthly = 4
}

Enum UptimeRobotMWindowStatus {
    Paused
    Active
}

Enum UptimeRobotPspSort {
    FriendlyNameAtoZ = 1
    FriendlyNameZtoA = 2
    StatusUpDownPaused = 3
    StatusDownUpPaused = 4
}
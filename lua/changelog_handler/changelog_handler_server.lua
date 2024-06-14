util.AddNetworkString("SendChangelog")
util.AddNetworkString("SendChangelogRequest")

ChangelogHandler = {}
ChangelogHandler.Changelogs = {
    {version = "1.0.0-Stable", log = "Version 1.0.0 Stable - Initial release"},
    {version = "1.0.1-Stable", log = "Version 1.0.1 Stable - Minor bugfixes"},
    {version = "1.0.2-Stable", log = "Version 1.0.1 Stable - New redirect to GitHub page"},
}
ChangelogHandler.CurrentVersion = "1.0.2-Stable"

-- function to send the most recent changelog to the client if it's newer than the last seen version
function ChangelogHandler:SendRecentChangelog(ply, lastSeenVersion)
    local mostRecentChangelog = self.Changelogs[#self.Changelogs]

    if mostRecentChangelog and mostRecentChangelog.version > lastSeenVersion then
        net.Start("SendChangelog")
        net.WriteTable({mostRecentChangelog})
        net.Send(ply)
    end
end

-- handle request from client for changelogs
net.Receive("SendChangelogRequest", function(len, ply)
    local lastSeenVersion = net.ReadString()
    ChangelogHandler:SendRecentChangelog(ply, lastSeenVersion)
end)

-- example command to manually trigger changelog (for testing)
hook.Add("PlayerSay", "ShowChangelogCommand", function(ply, text)
    if text == "!changelog" then
        local lastSeenVersion = "0.0"
        ChangelogHandler:SendRecentChangelog(ply, lastSeenVersion)
        return ""
    end
end)

concommand.Add("clear_changelog_entries", function(ply)
    if IsValid(ply) and ply:IsAdmin() then
        for _, player in ipairs(player.GetAll()) do
            player:SendLua("cookie.Delete('KeybindManager_LastSeenVersion')")
        end
        ply:ChatPrint("Changelog entries have been cleared for all players.")
    else
        print("Changelog entries have been cleared for all players.")
    end
end)

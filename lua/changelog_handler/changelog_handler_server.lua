-- Changelog Manager
ChangelogHandler = {}
ChangelogHandler.Changelogs = {
    {version = "1.0.0-Stable", log = "Version 1.0.0 Stable - Initial release"},
}
ChangelogHandler.CurrentVersion = "1.0.0-Stable"

util.AddNetworkString("SendChangelog")

-- Function to send recent changelogs to the client
function ChangelogHandler:SendRecentChangelogs(ply, lastSeenVersion)
    local recentChangelogs = {}
    for _, entry in ipairs(self.Changelogs) do
        if entry.version > lastSeenVersion then
            table.insert(recentChangelogs, entry.log)
        end
    end

    net.Start("SendChangelog")
    net.WriteTable(recentChangelogs)
    net.Send(ply)
end

-- Check the last seen version
function ChangelogHandler:GetLastSeenVersion(ply)
    return ply:GetPData("ChangelogVersion", "0.0")
end

function ChangelogHandler:ClearChangelogEntries()
    for _, ply in ipairs(player.GetAll()) do
        ply:SetPData("ChangelogVersion", "0.0")
    end
end


-- Mark changelog as seen for the player
function ChangelogHandler:MarkChangelogAsSeen(ply)
    ply:SetPData("ChangelogVersion", self.CurrentVersion)
end

-- Handle player joining to send the changelog
hook.Add("PlayerInitialSpawn", "SendChangelogOnJoin", function(ply)
    local lastSeenVersion = ChangelogHandler:GetLastSeenVersion(ply)
    ChangelogHandler:SendRecentChangelogs(ply, lastSeenVersion)
    ChangelogHandler:MarkChangelogAsSeen(ply)
end)

-- Example command to manually trigger changelog (for testing)
hook.Add("PlayerSay", "ShowChangelogCommand", function(ply, text)
    if text == "!changelog" then
        local lastSeenVersion = ChangelogHandler:GetLastSeenVersion(ply)
        ChangelogHandler:SendRecentChangelogs(ply, lastSeenVersion)
        ChangelogHandler:MarkChangelogAsSeen(ply)
        return ""
    end
end)

concommand.Add("clear_changelog_entries", function(ply)
    if IsValid(ply) and ply:IsAdmin() then
        ChangelogHandler:ClearChangelogEntries()
        ply:ChatPrint("Changelog entries have been cleared for all players.")
    else
        print("Changelog entries have been cleared for all players.")
    end
end)

-- Create a console variable to store the user's preference
if not ConVarExists("show_changelogs") then
    CreateConVar("show_changelogs", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Toggle the display of changelogs")
end

-- Function to get the last seen version from the client
local function GetLastSeenVersion()
    return cookie.GetString("KeybindManager_LastSeenVersion", "0.0")
end

-- Function to mark changelogs as seen
local function MarkChangelogAsSeen(version)
    cookie.Set("KeybindManager_LastSeenVersion", version)
end

net.Receive("SendChangelog", function()
    if not GetConVar("show_changelogs"):GetBool() then return end

    local changelogs = net.ReadTable()
    if #changelogs > 0 then
        local log = changelogs[1]  -- Use correct index

        if log then
            local lastSeenVersion = GetLastSeenVersion()

            if log.version > lastSeenVersion then
                chat.AddText("Recent changelogs for Keybind Manager:")
                chat.AddText(log.log)  -- Make sure to access the log property
                MarkChangelogAsSeen(log.version)
            end
        end
    end
end)

-- Request changelogs from the server when the client joins
hook.Add("InitPostEntity", "RequestChangelogOnJoin", function()
    local lastSeenVersion = GetLastSeenVersion()
    net.Start("SendChangelogRequest")
    net.WriteString(lastSeenVersion)
    net.SendToServer()
end)

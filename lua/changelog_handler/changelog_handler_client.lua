net.Receive("SendChangelog", function()
    if not GetConVar("show_changelogs"):GetBool() then return end

    local changelogs = net.ReadTable()
    if #changelogs > 0 then
        chat.AddText("Recent changelogs for Keybind Manager:")
        for _, log in ipairs(changelogs) do
            chat.AddText(log)
        end
    end
end)

-- Create a console variable to store the user's preference
if not ConVarExists("show_changelogs") then
    CreateConVar("show_changelogs", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Toggle the display of changelogs")
end

net.Receive("SendChangelog", function()
    local changelogs = net.ReadTable()
    if #changelogs > 0 then
        chat.AddText("Recent changelogs for Keybind Manager:")
        for _, log in ipairs(changelogs) do
            chat.AddText(log)
        end
    end
end)
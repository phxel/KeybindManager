-- keybind_manager/menu.lua
function KeybindManager:OpenMenu()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Keybind Manager")
    frame:SetSize(400, 600)
    frame:Center()
    frame:MakePopup()

    local scrollPanel = vgui.Create("DScrollPanel", frame)
    scrollPanel:Dock(FILL)

    -- Create the form for adding new keybinds
    local addPanel = vgui.Create("DPanel", scrollPanel)
    addPanel:Dock(TOP)
    addPanel:SetTall(250) -- Increased height to ensure all elements fit
    addPanel:DockMargin(0, 0, 0, 10)

    local nameLabel = vgui.Create("DLabel", addPanel)
    nameLabel:SetText("Keybind Name:")
    nameLabel:Dock(TOP)
    nameLabel:SetTextColor(Color(0, 0, 0))
    nameLabel:DockMargin(0, 0, 0, 5)

    local nameEntry = vgui.Create("DTextEntry", addPanel)
    nameEntry:Dock(TOP)
    nameEntry:DockMargin(0, 0, 0, 10)

    local descriptionLabel = vgui.Create("DLabel", addPanel)
    descriptionLabel:SetText("Description:")
    descriptionLabel:Dock(TOP)
    descriptionLabel:SetTextColor(Color(0, 0, 0))
    descriptionLabel:DockMargin(0, 0, 0, 5)

    local descriptionEntry = vgui.Create("DTextEntry", addPanel)
    descriptionEntry:Dock(TOP)
    descriptionEntry:DockMargin(0, 0, 0, 10)

    local commandLabel = vgui.Create("DLabel", addPanel)
    commandLabel:SetText("Console Command:")
    commandLabel:Dock(TOP)
    commandLabel:SetTextColor(Color(0, 0, 0))
    commandLabel:DockMargin(0, 0, 0, 5)

    local commandEntry = vgui.Create("DTextEntry", addPanel)
    commandEntry:Dock(TOP)
    commandEntry:DockMargin(0, 0, 0, 10)

    local keyLabel = vgui.Create("DLabel", addPanel)
    keyLabel:SetText("Key:")
    keyLabel:Dock(TOP)
    keyLabel:SetTextColor(Color(0, 0, 0))
    keyLabel:DockMargin(0, 0, 0, 5)

    local keySelector = vgui.Create("DBinder", addPanel)
    keySelector:Dock(TOP)
    keySelector:SetWide(150)
    keySelector:DockMargin(0, 0, 0, 10)

    local addButton = vgui.Create("DButton", addPanel)
    addButton:SetText("Add Keybind")
    addButton:Dock(TOP)
    addButton:DockMargin(0, 0, 0, 10)
    addButton.DoClick = function()
        local name = nameEntry:GetValue()
        local description = descriptionEntry:GetValue()
        local key = keySelector:GetValue()
        local command = commandEntry:GetValue()
    
        if name and key and description and command then
            KeybindManager:RegisterKeybind(name, key, description, command)
            nameEntry:SetValue("")
            descriptionEntry:SetValue("")
            keySelector:SetValue(0)
            commandEntry:SetValue("")
            frame:Close()
            KeybindManager:OpenMenu()
        end
    end

    -- Display existing keybinds
    for name, bind in pairs(KeybindManager.Keybinds) do
        local panel = scrollPanel:Add("DPanel")
        panel:Dock(TOP)
        panel:SetTall(50)
        panel:DockMargin(0, 0, 0, 5)

        local label = vgui.Create("DLabel", panel)
        label:SetText(name .. " (" .. bind.description .. ")")
        label:Dock(LEFT)
        label:SetWide(200)
        label:SetTextColor(Color(0, 0, 0))
        label:SetContentAlignment(5)

        local keySelector = vgui.Create("DBinder", panel)
        keySelector:SetValue(bind.key)
        keySelector:Dock(RIGHT)
        keySelector:SetWide(150)
        keySelector.OnChange = function(_, newKey)
            bind.key = newKey
            KeybindManager:SaveKeybinds() -- Save keybinds when they are modified
        end

        local deleteButton = vgui.Create("DButton", panel)
        deleteButton:SetText("Delete")
        deleteButton:Dock(RIGHT)
        deleteButton:SetWide(50)
        deleteButton:DockMargin(5, 0, 0, 0)
        deleteButton.DoClick = function()
            KeybindManager.Keybinds[name] = nil
            KeybindManager:SaveKeybinds()
            frame:Close()
            KeybindManager:OpenMenu()
        end
    end
end
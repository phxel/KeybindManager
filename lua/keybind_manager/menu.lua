function KeybindManager:OpenMenu()
    if IsValid(KeybindManager.Menu) then
        KeybindManager.Menu:SetVisible(true)
        KeybindManager.Menu:MakePopup()
        return
    end

    local menu = vgui.Create("DFrame")
    menu:SetTitle("Keybind Manager")
    menu:SetSize(600, 400)
    menu:Center()
    menu:MakePopup()

    local leftPanel = vgui.Create("DPanel", menu)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(200)
    leftPanel:DockMargin(5, 5, 5, 5)
    leftPanel:DockPadding(5, 5, 5, 5)

    local rightPanel = vgui.Create("DPanel", menu)
    rightPanel:Dock(FILL)
    rightPanel:DockMargin(0, 5, 5, 5)
    rightPanel:DockPadding(5, 5, 5, 5)

    local keybindList = vgui.Create("DListView", leftPanel)
    keybindList:Dock(FILL)
    keybindList:AddColumn("Keybind")
    keybindList:SetMultiSelect(false)

    local function populateKeybindList()
        keybindList:Clear()
        for name, bind in pairs(KeybindManager.Keybinds) do
            keybindList:AddLine(name)
        end
    end

    local nameLabel = vgui.Create("DLabel", rightPanel)
    nameLabel:SetText("Keybind Name:")
    nameLabel:Dock(TOP)
    nameLabel:SetTextColor(Color(0, 0, 0))
    nameLabel:DockMargin(0, 0, 0, 5)

    local nameEntry = vgui.Create("DTextEntry", rightPanel)
    nameEntry:Dock(TOP)
    nameEntry:DockMargin(0, 0, 0, 10)

    local descriptionLabel = vgui.Create("DLabel", rightPanel)
    descriptionLabel:SetText("Description:")
    descriptionLabel:Dock(TOP)
    descriptionLabel:SetTextColor(Color(0, 0, 0))
    descriptionLabel:DockMargin(0, 0, 0, 5)

    local descriptionEntry = vgui.Create("DTextEntry", rightPanel)
    descriptionEntry:Dock(TOP)
    descriptionEntry:DockMargin(0, 0, 0, 10)

    local commandLabel = vgui.Create("DLabel", rightPanel)
    commandLabel:SetText("Console Command:")
    commandLabel:Dock(TOP)
    commandLabel:SetTextColor(Color(0, 0, 0))
    commandLabel:DockMargin(0, 0, 0, 5)

    local commandEntry = vgui.Create("DTextEntry", rightPanel)
    commandEntry:Dock(TOP)
    commandEntry:DockMargin(0, 0, 0, 10)

    local keyLabel = vgui.Create("DLabel", rightPanel)
    keyLabel:SetText("Key:")
    keyLabel:Dock(TOP)
    keyLabel:SetTextColor(Color(0, 0, 0))
    keyLabel:DockMargin(0, 0, 0, 5)

    local keySelector = vgui.Create("DBinder", rightPanel)
    keySelector:Dock(TOP)
    keySelector:SetWide(150)
    keySelector:DockMargin(0, 0, 0, 10)

    local isDefaultActionCheckbox = vgui.Create("DCheckBoxLabel", rightPanel)
    isDefaultActionCheckbox:SetText("Is Default Action")
    isDefaultActionCheckbox:Dock(TOP)
    isDefaultActionCheckbox:SetTextColor(Color(0, 0, 0))
    isDefaultActionCheckbox:DockMargin(0, 0, 0, 10)

    local addButton = vgui.Create("DButton", rightPanel)
    addButton:SetText("Add/Update Keybind")
    addButton:Dock(TOP)
    addButton:DockMargin(0, 0, 0, 5)
    addButton.DoClick = function()
        local name = nameEntry:GetValue()
        local description = descriptionEntry:GetValue()
        local key = keySelector:GetValue()
        local command = commandEntry:GetValue()
        local isDefaultAction = isDefaultActionCheckbox:GetChecked()

        if name and key and description and command then
            KeybindManager:RegisterKeybind(name, key, description, command, isDefaultAction)
            populateKeybindList()
        end
    end

    local deleteButton = vgui.Create("DButton", rightPanel)
    deleteButton:SetText("Delete Keybind")
    deleteButton:Dock(TOP)
    deleteButton:DockMargin(0, 0, 0, 5)
    deleteButton.DoClick = function()
        local selectedLine = keybindList:GetSelectedLine()
        if selectedLine then
            local name = keybindList:GetLine(selectedLine):GetValue(1)
            local bind = KeybindManager.Keybinds[name]
            if bind then
                local defaultBind = input.LookupBinding(bind.command) or ""
                KeybindManager.Keybinds[name] = nil
                KeybindManager:SaveKeybinds()

                if bind.isDefaultAction then
                    RunConsoleCommand("bind", defaultBind, bind.command)
                end

                populateKeybindList()
            end
        end
    end

    keybindList.OnRowSelected = function(_, _, line)
        local name = line:GetValue(1)
        local bind = KeybindManager.Keybinds[name]
        if bind then
            nameEntry:SetValue(name)
            descriptionEntry:SetValue(bind.description)
            commandEntry:SetValue(bind.command)
            keySelector:SetValue(bind.key)
            isDefaultActionCheckbox:SetChecked(bind.isDefaultAction)
        end
    end

    populateKeybindList()

    KeybindManager.Menu = menu
end
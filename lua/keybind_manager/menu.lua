local keybindList

function KeybindManager:OpenMenu()
    if IsValid(KeybindManager.Menu) then
        KeybindManager.Menu:SetVisible(true)
        KeybindManager.Menu:MakePopup()
        return
    end

    -- Utility function to create a label
    local function createLabel(parent, text)
        local label = vgui.Create("DLabel", parent)
        label:SetText(text)
        label:SetFont("DermaDefaultBold")
        label:SetTextColor(Color(255, 255, 255))
        label:Dock(TOP)
        label:DockMargin(0, 0, 0, 5)
        return label
    end

    -- Main Frame
    local menu = vgui.Create("DFrame")
    menu:SetTitle("Keybind Manager")
    menu:SetSize(600, 500)
    menu:Center()
    menu:MakePopup()
    menu:SetDraggable(true)
    menu:ShowCloseButton(true)
    menu.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 230))
    end

    -- Profile Management
    local profilePanel = vgui.Create("DPanel", menu)
    profilePanel:Dock(TOP)
    profilePanel:SetTall(50)
    profilePanel:DockMargin(5, 5, 5, 5)
    profilePanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 230))
    end

    createLabel(profilePanel, "Profile:")
    local profileComboBox = vgui.Create("DComboBox", profilePanel)
    profileComboBox:Dock(FILL)
    profileComboBox:SetValue(KeybindManager.CurrentProfile)
    for profileName, _ in pairs(KeybindManager.Profiles) do
        profileComboBox:AddChoice(profileName)
    end

    local function populateKeybindList()
        keybindList:Clear()
        for name, bind in pairs(KeybindManager.Keybinds) do
            keybindList:AddLine(name)
        end
    end

    profileComboBox.OnSelect = function(panel, index, value)
        KeybindManager:LoadProfile(value)
        populateKeybindList()
    end

    local newProfileButton = vgui.Create("DButton", profilePanel)
    newProfileButton:SetText("New Profile")
    newProfileButton:Dock(RIGHT)
    newProfileButton:SetWide(100)
    newProfileButton.DoClick = function()
        Derma_StringRequest(
            "New Profile",
            "Enter profile name:",
            "",
            function(text)
                if text and text ~= "" then
                    KeybindManager:SaveProfile(text)
                    profileComboBox:AddChoice(text)
                    profileComboBox:SetValue(text)
                    KeybindManager:LoadProfile(text)
                    populateKeybindList()
                end
            end
        )
    end

    local deleteProfileButton = vgui.Create("DButton", profilePanel)
    deleteProfileButton:SetText("Delete Profile")
    deleteProfileButton:Dock(RIGHT)
    deleteProfileButton:SetWide(100)
    deleteProfileButton.DoClick = function()
        local selectedProfile = profileComboBox:GetValue()
        if selectedProfile and selectedProfile ~= "" then
            KeybindManager.Profiles[selectedProfile] = nil
            if selectedProfile == KeybindManager.CurrentProfile then
                KeybindManager.CurrentProfile = "default"
                KeybindManager.Keybinds = KeybindManager.Profiles["default"] or {}
            end
            KeybindManager:SaveKeybinds()
    
            -- Clear the existing choices in the profileComboBox
            profileComboBox:Clear()
    
            -- Re-add the updated list of profiles to the profileComboBox
            for profileName, _ in pairs(KeybindManager.Profiles) do
                profileComboBox:AddChoice(profileName)
            end
    
            -- Set the selected profile to the current profile
            profileComboBox:SetValue(KeybindManager.CurrentProfile)
    
            populateKeybindList()
        end
    end
    
    -- Right Panel (Keybind List)
    local rightPanel = vgui.Create("DPanel", menu)
    rightPanel:Dock(RIGHT)
    rightPanel:SetWide(250)
    rightPanel:DockMargin(5, 5, 5, 5)
    rightPanel:DockPadding(5, 5, 5, 5)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 230))
    end

    -- Left Panel (Keybind Details)
    local leftPanel = vgui.Create("DPanel", menu)
    leftPanel:Dock(FILL)
    leftPanel:DockMargin(5, 5, 5, 5)
    leftPanel:DockPadding(5, 5, 5, 5)
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 70, 230))
    end

    -- Keybind List
    keybindList = vgui.Create("DListView", rightPanel)
    keybindList:Dock(FILL)
    keybindList:AddColumn("Keybind")
    keybindList:SetMultiSelect(false)
    keybindList:SetHeaderHeight(30)
    keybindList:SetDataHeight(25)

    -- Call the population function after the list has been created
    populateKeybindList()

    -- Keybind Detail Controls
    createLabel(leftPanel, "Keybind Name:")
    local nameEntry = vgui.Create("DTextEntry", leftPanel)
    nameEntry:Dock(TOP)
    nameEntry:DockMargin(0, 0, 0, 10)

    createLabel(leftPanel, "Description:")
    local descriptionEntry = vgui.Create("DTextEntry", leftPanel)
    descriptionEntry:Dock(TOP)
    descriptionEntry:DockMargin(0, 0, 0, 10)

    createLabel(leftPanel, "Console Command:")
    local commandEntry = vgui.Create("DTextEntry", leftPanel)
    commandEntry:Dock(TOP)
    commandEntry:DockMargin(0, 0, 0, 10)

    createLabel(leftPanel, "Key:")
    local keySelector = vgui.Create("DBinder", leftPanel)
    keySelector:Dock(TOP)
    keySelector:SetWide(150)
    keySelector:DockMargin(0, 0, 0, 10)

    local isDefaultActionCheckbox = vgui.Create("DCheckBoxLabel", leftPanel)
    isDefaultActionCheckbox:SetText("Is Default Action")
    isDefaultActionCheckbox:Dock(TOP)
    isDefaultActionCheckbox:SetTextColor(Color(255, 255, 255))
    isDefaultActionCheckbox:DockMargin(0, 0, 0, 10)

    -- Action Buttons
    local addButton = vgui.Create("DButton", leftPanel)
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

    local deleteButton = vgui.Create("DButton", leftPanel)
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

    KeybindManager.Menu = menu
end

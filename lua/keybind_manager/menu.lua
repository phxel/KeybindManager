local nameEntry, descriptionEntry, commandEntry, keySelector, releaseCommandEntry

function KeybindManager:OpenMenu()
    if IsValid(KeybindManager.Menu) then
        KeybindManager.Menu:SetVisible(true)
        KeybindManager.Menu:MakePopup()
        return
    end

    -- function to create labels so i don't have to repeat myself a gazillion times
    local function createLabel(parent, text)
        local label = vgui.Create("DLabel", parent)
        label:SetText(text)
        label:SetFont("DermaDefault")
        label:SetTextColor(Color(255, 255, 255))
        label:Dock(TOP)
        label:DockMargin(0, 0, 0, 5)
        return label
    end

    local menu = vgui.Create("DFrame")
    menu:SetTitle("Keybind Manager")
    menu:SetSize(600, 550)
    menu:Center()
    menu:MakePopup()
    menu:SetDraggable(true)
    menu:ShowCloseButton(true)
    menu.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(75, 75, 75, 200))
    end

    local profilePanel = vgui.Create("DPanel", menu)
    profilePanel:Dock(TOP)
    profilePanel:SetTall(50)
    profilePanel:DockMargin(5, 5, 5, 5)
    profilePanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 230))
    end

    createLabel(profilePanel, " Profile:")
    local profileComboBox = vgui.Create("DComboBox", profilePanel)
    profileComboBox:Dock(FILL)
    profileComboBox:SetValue(KeybindManager.CurrentProfile)
    for profileName, _ in pairs(KeybindManager.Profiles) do
        profileComboBox:AddChoice(profileName)
    end

    -- clear keybind list, used to reload the keybind table
    local function clearKeybindEntries()
        nameEntry:SetValue("")
        descriptionEntry:SetValue("")
        commandEntry:SetValue("")
        keySelector:SetValue(0)
        releaseCommandEntry:SetValue("")
    end

    -- read keybinds from profile and populate the table again
    local function populateKeybindList()
        keybindList:Clear()
        for name, bind in pairs(KeybindManager.Profiles[KeybindManager.CurrentProfile] or {}) do
            keybindList:AddLine(name)
        end
    end

    -- on profile change, clear keybind list and repopulate
    hook.Add("KeybindManagerProfileChanged", "ReloadKeybindList", function()
        populateKeybindList()
        clearKeybindEntries()
    end)

    profileComboBox.OnSelect = function(panel, index, value)
        KeybindManager:LoadProfile(value)
        KeybindManager:SaveLastProfile()
        populateKeybindList()
        clearKeybindEntries()
    end

    local newProfileButton = vgui.Create("DButton", profilePanel)
    newProfileButton:SetText("New Profile")
    newProfileButton:Dock(RIGHT)
    newProfileButton:SetWide(100)
    newProfileButton.DoClick = function()
        Derma_StringRequest("New Profile", "Enter profile name:", "", function(text)
            if text and text ~= "" then
                KeybindManager:SaveProfile(text)
                KeybindManager:SaveLastProfile()
                profileComboBox:AddChoice(text)
                profileComboBox:SetValue(text)
                KeybindManager:LoadProfile(text)
                populateKeybindList()
            end
        end)
    end

    local deleteProfileButton = vgui.Create("DButton", profilePanel)
    deleteProfileButton:SetText("Delete Profile")
    deleteProfileButton:Dock(RIGHT)
    deleteProfileButton:SetWide(100)
    deleteProfileButton.DoClick = function()
        local selectedProfile = profileComboBox:GetValue()
        if selectedProfile and selectedProfile ~= "" and selectedProfile ~= "default" then
            KeybindManager.Profiles[selectedProfile] = nil
            if selectedProfile == KeybindManager.CurrentProfile then
                KeybindManager.CurrentProfile = "default"
                KeybindManager.Keybinds = KeybindManager.Profiles["default"] or {}
            end
            file.Delete("keybindmanager/" .. selectedProfile .. ".json")

            profileComboBox:Clear()
            for profileName, _ in pairs(KeybindManager.Profiles) do
                profileComboBox:AddChoice(profileName)
            end
            profileComboBox:SetValue(KeybindManager.CurrentProfile)

            populateKeybindList()
            clearKeybindEntries()
        else
            print("[KeybindManager] Cannot delete default or invalid profile.")
        end
    end

    local rightPanel = vgui.Create("DPanel", menu)
    rightPanel:Dock(RIGHT)
    rightPanel:SetWide(250)
    rightPanel:DockMargin(5, 5, 5, 5)
    rightPanel:DockPadding(5, 5, 5, 5)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 230))
    end

    local leftPanel = vgui.Create("DPanel", menu)
    leftPanel:Dock(FILL)
    leftPanel:DockMargin(5, 5, 5, 5)
    leftPanel:DockPadding(5, 5, 5, 5)
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(70, 70, 70, 230))
    end

    keybindList = vgui.Create("DListView", rightPanel)
    keybindList:Dock(FILL)
    keybindList:AddColumn("Keybind")
    keybindList:SetMultiSelect(false)
    keybindList:SetHeaderHeight(30)
    keybindList:SetDataHeight(25)

    -- create necessary labels
    createLabel(leftPanel, "Keybind Name:")
    nameEntry = vgui.Create("DTextEntry", leftPanel)
    nameEntry:Dock(TOP)
    nameEntry:DockMargin(0, 0, 0, 10)

    createLabel(leftPanel, "Description:")
    descriptionEntry = vgui.Create("DTextEntry", leftPanel)
    descriptionEntry:Dock(TOP)
    descriptionEntry:DockMargin(0, 0, 0, 10)

    createLabel(leftPanel, "Console Command:")
    commandEntry = vgui.Create("DTextEntry", leftPanel)
    commandEntry:Dock(TOP)
    commandEntry:DockMargin(0, 0, 0, 10)

    createLabel(leftPanel, "Key:")
    keySelector = vgui.Create("DBinder", leftPanel)
    keySelector:Dock(TOP)
    keySelector:SetWide(150)
    keySelector:DockMargin(0, 0, 0, 10)
    keySelector:SetTextColor(Color(0,0,0))

    createLabel(leftPanel, "Release Command (optional):")
    releaseCommandEntry = vgui.Create("DTextEntry", leftPanel)
    releaseCommandEntry:Dock(TOP)
    releaseCommandEntry:DockMargin(0, 0, 0, 10)


    local addButton = vgui.Create("DButton", leftPanel)
    addButton:SetText("Add/Update Keybind")
    addButton:Dock(TOP)
    addButton:DockMargin(0, 0, 0, 5)
    addButton.DoClick = function()
        local name = nameEntry:GetValue()
        local description = descriptionEntry:GetValue()
        local key = keySelector:GetValue()
        local command = commandEntry:GetValue()
        local releaseCommand = releaseCommandEntry:GetValue()

        if name and key and description and command then
            KeybindManager:RegisterKeybind(name, key, description, command, releaseCommand)
            populateKeybindList()
        else
            print("[KeybindManager] Invalid keybind details.")
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
            local bind = KeybindManager.Profiles[KeybindManager.CurrentProfile][name]
            if bind then
                local defaultBind = input.LookupBinding(bind.command) or ""
                KeybindManager.Profiles[KeybindManager.CurrentProfile][name] = nil
                KeybindManager:SaveKeybinds()
                populateKeybindList()
            else
                print("[KeybindManager] Keybind not found.")
            end
        else
            print("[KeybindManager] No keybind selected for deletion.")
        end
    end

    keybindList.OnRowSelected = function(_, _, line)
        local name = line:GetValue(1)
        local bind = KeybindManager.Profiles[KeybindManager.CurrentProfile][name]
        if bind then
            nameEntry:SetValue(name)
            descriptionEntry:SetValue(bind.description)
            commandEntry:SetValue(bind.command)
            keySelector:SetValue(bind.key)
            releaseCommandEntry:SetValue(bind.releaseCommand or "")
        else
            print("[KeybindManager] Keybind not found in the profile.")
        end
    end

    KeybindManager:LoadLastProfile()
    KeybindManager:LoadKeybinds()
    populateKeybindList()
    clearKeybindEntries()

    KeybindManager.Menu = menu
end

-- I have concluded that derma is like css, but horrible
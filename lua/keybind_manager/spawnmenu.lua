-- Create a new tab in the spawnmenu
hook.Add("PopulateToolMenu", "KeybindManager_PopulateToolMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "Keybind Manager", "KeybindManager", "Keybind Manager", "", "", function(panel)
        panel:ClearControls()

        local openMenuButton = vgui.Create("DButton", panel)
        openMenuButton:SetText("Open Keybind Manager")
        openMenuButton:Dock(TOP)
        openMenuButton:DockMargin(10, 10, 10, 0)
        openMenuButton.DoClick = function()
            KeybindManager:OpenMenu()
        end
    end)
end)
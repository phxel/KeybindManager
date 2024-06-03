if SERVER then
    -- Include server-side initialization if needed
    include("keybind_manager/core.lua")
else
    -- Ensure the KeybindManager table is initialized
    KeybindManager = KeybindManager or {}

    -- Include the core functionality and menu
    include("keybind_manager/core.lua")
    include("keybind_manager/menu.lua")

    -- Load existing keybinds
    KeybindManager:LoadKeybinds()

    -- Add a console command to open the keybind manager menu
    concommand.Add("open_keybind_manager", function()
        KeybindManager:OpenMenu()
    end)
end
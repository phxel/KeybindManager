if SERVER then
    include("keybind_manager/core/server_core.lua")
else
    KeybindManager = KeybindManager or {}
    include("keybind_manager/core/client_core.lua")
    include("keybind_manager/menu.lua")
    include("keybind_manager/spawnmenu.lua")
    KeybindManager:LoadKeybinds()
    concommand.Add("open_keybind_manager", function()
        KeybindManager:OpenMenu()
    end)
end

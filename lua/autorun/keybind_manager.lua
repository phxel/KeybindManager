if SERVER then
    include("keybind_manager/core.lua")
else
    KeybindManager = KeybindManager or {}
    include("keybind_manager/core.lua")
    include("keybind_manager/menu.lua")
    KeybindManager:LoadKeybinds()
    concommand.Add("open_keybind_manager", function()
        KeybindManager:OpenMenu()
    end)
end
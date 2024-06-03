if SERVER then
    include("keybind_manager/core.lua")
else
    KeybindManager = KeybindManager or {} -- initialize table 

    include("keybind_manager/core.lua")
    include("keybind_manager/menu.lua")

    KeybindManager:LoadKeybinds() -- load existing keybinds if present in json

    concommand.Add("open_keybind_manager", function()
        KeybindManager:OpenMenu() -- call function if command is entered in console
    end)
end

if SERVER then
    include("keybind_manager/core/server_core.lua") -- include server functionality
else
    KeybindManager = KeybindManager or {}
    include("keybind_manager/core/client_core.lua") -- include client functionality
    include("keybind_manager/menu.lua") -- derma menu for easier registering of keybinds
    include("keybind_manager/spawnmenu.lua") -- spawnmenu integration
    KeybindManager:LoadKeybinds() -- load saved profiles & keybinds
    concommand.Add("open_keybind_manager", function() 
        KeybindManager:OpenMenu()
    end)
end

--[[

    TODO Features:
    - Add user-defined customization to the menu (Theming and whatnot) # OPEN
    - Reformat .json tables (Currently, keybinds and the attributes they possess are saved on a single line) # CLOSED
    - Reformat codebase for easier maintanance # CLOSED
    - Ability to share profiles between clients (Should be feasible) # OPEN
    - Extend API to allow other developers to create their own profiles/integrate functionality from this addon # OPEN

    - Redesign the menu again, maybe.
    
--]]
